#!/usr/bin/env python3
"""Catálogo dos meus comandos (fonte única do `ajuda` e do widget CommandShelf).

Só LÊ arquivos e serializa metadados: nunca executa, faz `source` nem expande
nada dos arquivos lidos, e não acessa rede.

Uso:
  commands.py [--json | --tsv] [--home DIR] [--etc-bashrc FILE]

--json (padrão): {"version":1,"categories":[...],"commands":[...],"warnings":[...]}
--tsv: 5 colunas pro renderizador do `ajuda`:
       categoria(1-5) <TAB> ícone <TAB> nome <TAB> detalhe <TAB> descrição
"""

import argparse
import json
from pathlib import Path
import re
import shlex
import stat
import sys

VERSION = 1

CATEGORIES = [
    {"id": "shell", "title": "Shell", "icon": "terminal"},
    {"id": "scripts", "title": "Scripts", "icon": "code"},
    {"id": "nix", "title": "NixOS", "icon": "deployed_code"},
    {"id": "ssh", "title": "SSH", "icon": "dns"},
    {"id": "desktop", "title": "Atalhos", "icon": "keyboard"},
]
TSV_SECTION = {"shell": "1", "scripts": "2", "nix": "3", "ssh": "4", "desktop": "5"}

# Atalhos do desktop (Win/Super): lista única, usada pelo `ajuda` e pelo widget.
DESKTOP_SHORTCUTS = [
    ("Win + Espaço", "Dolphin"),
    ("Win + Tab", "Overview preservado"),
    ("Win + Shift + C", "Calculadora"),
    ("Win + Ctrl + W", "Carrossel de wallpapers"),
    ("Win + Ctrl + D", "Docker Manager"),
    ("Win + Shift + B", "Bitwarden"),
]

# Nerd Font glyphs do renderizador do `ajuda` (só vão no TSV).
GLYPH_FUNCTION = "\U000f0295"
GLYPH_GITHUB = "\uf09b"
GLYPH_TAILSCALE = "\uf132"
GLYPH_LAN = "\uf233"
GLYPH_TUNNEL = "\uf0ec"
GLYPH_SSH = "\uf120"

DESC_PREFIX = "#: "
NAME = r"[A-Za-z_][A-Za-z0-9_]*"
FUNCTION_OPEN = re.compile(rf"^(?:function\s+({NAME})\s*(?:\(\))?|({NAME})\s*\(\))\s*\{{(.*)$")
ONE_LINER = re.compile(r"^\s*(.*?);\s*\}\s*$")
ALIAS_NAME = re.compile(r"^[^\s=/$`'\"]+$")
SCRIPT_HEAD_BYTES = 64 * 1024
TSV_DETAIL_LIMIT = 40


class Catalog:
    def __init__(self):
        self.commands = []
        self.warnings = []
        self._ids = set()

    def add(self, category, kind, name, command, detail, description, source, glyph=""):
        base = f"{category}:{kind}:{name}"
        uid, n = base, 1
        while uid in self._ids:
            n += 1
            uid = f"{base}#{n}"
        self._ids.add(uid)
        self.commands.append({
            "id": uid,
            "category": category,
            "name": name,
            "command": command,
            "detail": detail,
            "description": description,
            "kind": kind,
            "source": source,
            "_glyph": glyph,
        })


def display_path(path, home):
    try:
        return "~/" + str(Path(path).relative_to(home))
    except ValueError:
        return str(path)


def copy_name(name):
    return name if re.fullmatch(r"[A-Za-z0-9_@%+=:,./-]+", name) else shlex.quote(name)


def parse_alias_line(line):
    """`alias a='x' b=y` -> [(a, x), (b, y)] sem expandir nada; None se não der pra ler."""
    try:
        words = shlex.split(line[len("alias"):], comments=True, posix=True)
    except ValueError:
        return None
    pairs = []
    for word in words:
        if word == "--" or (word.startswith("-") and "=" not in word):
            continue
        name, sep, value = word.partition("=")
        if sep and ALIAS_NAME.match(name):
            pairs.append((name, value))
    return pairs


def read_text(path, catalog, home, limit=None):
    """Conteúdo de um arquivo opcional; ausente -> None sem aviso."""
    try:
        with open(path, "rb") as handle:
            data = handle.read() if limit is None else handle.read(limit)
    except FileNotFoundError:
        return None
    except OSError as error:
        catalog.warnings.append(f"{display_path(path, home)}: {error.strerror or error}")
        return None
    return data.decode("utf-8", errors="replace")


def parse_bashrc(text, source, catalog, *, category_for, alias_kind="alias", functions=True):
    """alias/funções de topo com "#: descrição" logo acima (linhas seguidas se juntam).

    Corpos de funções multilinha são pulados até o `}` na coluna 0, então nada
    declarado dentro deles vira comando.
    """
    desc_lines = []
    in_body = False
    for number, line in enumerate(text.splitlines(), 1):
        if in_body:
            if line.startswith("}"):
                in_body = False
            continue
        if line.startswith(DESC_PREFIX):
            desc_lines.append(line[len(DESC_PREFIX):].strip())
            continue
        desc = " ".join(part for part in desc_lines if part)
        desc_lines = []
        if line.startswith("alias "):
            pairs = parse_alias_line(line)
            if pairs is None:
                catalog.warnings.append(f"{source}:{number}: alias ignorado (aspas não fechadas)")
                continue
            for name, value in pairs:
                catalog.add(category_for(name), alias_kind, name, copy_name(name), value, desc, source)
            continue
        match = FUNCTION_OPEN.match(line)
        if match:
            name = match.group(1) or match.group(2)
            rest = match.group(3)
            one_liner = ONE_LINER.match(rest)
            if one_liner:
                detail = one_liner.group(1).strip()
            else:
                detail = "função"
                in_body = rest.strip() != "}" and not rest.rstrip().endswith("}")
            if functions:
                catalog.add(category_for(name), "function", name, copy_name(name), detail, desc,
                            source, GLYPH_FUNCTION)


def bashrc_category(name):
    return "nix" if name.startswith("nix") else "shell"


def scan_scripts(directory, catalog, home):
    """Só scripts meus: arquivo regular (não symlink) começando com `#!`."""
    try:
        entries = sorted(Path(directory).iterdir(), key=lambda p: p.name)
    except FileNotFoundError:
        return
    except OSError as error:
        catalog.warnings.append(f"{display_path(directory, home)}: {error.strerror or error}")
        return
    for path in entries:
        if path.name.startswith("."):
            continue
        try:
            info = path.lstat()
        except OSError:
            continue
        if not stat.S_ISREG(info.st_mode):
            continue
        text = read_text(path, catalog, home, SCRIPT_HEAD_BYTES)
        if text is None or not text.startswith("#!"):
            continue
        desc = next((line[len(DESC_PREFIX):].strip() for line in text.splitlines()
                     if line.startswith(DESC_PREFIX)), "")
        catalog.add("scripts", "script", path.name, copy_name(path.name), "", desc,
                    display_path(path, home))


def ssh_keyword(line):
    """`Key value` / `Key=value` -> (key minúsculo, [args])."""
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return None, []
    match = re.match(r"^([A-Za-z]+)\s*(?:=\s*|\s+)(.*)$", stripped)
    if not match:
        return stripped.lower(), []
    try:
        args = shlex.split(match.group(2), comments=True, posix=True)
    except ValueError:
        args = match.group(2).split()
    return match.group(1).lower(), args


def is_concrete_host(pattern):
    return bool(pattern) and not pattern.startswith("!") and not any(c in pattern for c in "*?%")


def ssh_glyph(hostname, forwards):
    if forwards:
        return GLYPH_TUNNEL
    if "github" in hostname:
        return GLYPH_GITHUB
    if hostname.startswith("100.") or hostname.endswith(".ts.net"):
        return GLYPH_TAILSCALE
    if hostname.startswith("192.168.") or hostname.startswith("10."):
        return GLYPH_LAN
    return GLYPH_SSH


def parse_ssh_config(text, source, catalog):
    """Hosts concretos (sem curingas/negação) com "#: descrição" acima do `Host`."""
    pending = []
    stanza = None

    def flush():
        if not stanza:
            return
        hostname, user, forwards = stanza["hostname"], stanza["user"], stanza["forwards"]
        desc = stanza["desc"]
        if forwards:
            desc = (desc + " · " if desc else "") + "túnel " + ", ".join(forwards)
        for alias in stanza["hosts"]:
            target = hostname or alias
            detail = f"{user}@{target}" if user else target
            catalog.add("ssh", "ssh", alias, "ssh " + shlex.quote(alias), detail, desc, source,
                        ssh_glyph(hostname, forwards))

    for line in text.splitlines():
        if line.startswith(DESC_PREFIX):
            if stanza is not None:
                flush()
                stanza = None
            pending.append(line[len(DESC_PREFIX):].strip())
            continue
        key, args = ssh_keyword(line)
        if key == "host":
            flush()
            stanza = {
                "hosts": [p for p in args if is_concrete_host(p)],
                "desc": " ".join(part for part in pending if part),
                "hostname": "", "user": "", "forwards": [],
            }
            pending = []
        elif key == "match":
            flush()
            stanza = None
            pending = []
        elif stanza is not None and args:
            if key == "hostname" and not stanza["hostname"]:
                stanza["hostname"] = args[0]
            elif key == "user" and not stanza["user"]:
                stanza["user"] = args[0]
            elif key == "localforward" and len(args) >= 2:
                listen = args[0] if ":" in args[0] or "/" in args[0] else "localhost:" + args[0]
                stanza["forwards"].append(f"{listen} → {args[1]}")
    flush()


def collect(home=None, etc_bashrc="/etc/bashrc"):
    home = Path(home) if home is not None else Path.home()
    catalog = Catalog()

    bashrc = home / ".bashrc"
    text = read_text(bashrc, catalog, home)
    if text is not None:
        parse_bashrc(text, display_path(bashrc, home), catalog, category_for=bashrc_category)

    scan_scripts(home / ".local" / "bin", catalog, home)

    text = read_text(etc_bashrc, catalog, home)
    if text is not None:
        parse_bashrc(text, str(etc_bashrc), catalog, category_for=lambda _: "nix",
                     alias_kind="system-alias", functions=False)

    ssh_config = home / ".ssh" / "config"
    text = read_text(ssh_config, catalog, home)
    if text is not None:
        parse_ssh_config(text, display_path(ssh_config, home), catalog)

    for keys, description in DESKTOP_SHORTCUTS:
        catalog.add("desktop", "shortcut", keys, keys, "", description, "niri")

    return catalog


def to_json(catalog):
    commands = [{k: v for k, v in c.items() if not k.startswith("_")} for c in catalog.commands]
    return {"version": VERSION, "categories": CATEGORIES, "commands": commands,
            "warnings": list(catalog.warnings)}


def tsv_field(value):
    return re.sub(r"[\t\r\n]+", " ", value)


def to_tsv(catalog):
    rows = []
    for c in catalog.commands:
        detail = c["detail"]
        if c["kind"] in ("alias", "function") and len(detail) > TSV_DETAIL_LIMIT:
            detail = detail[:TSV_DETAIL_LIMIT - 1] + "…"
        fields = (TSV_SECTION[c["category"]], c["_glyph"], c["name"], detail, c["description"])
        rows.append("\t".join(tsv_field(f) for f in fields) + "\n")
    return "".join(rows)


def main(argv=None):
    parser = argparse.ArgumentParser(description="Catálogo dos meus comandos (só leitura).")
    fmt = parser.add_mutually_exclusive_group()
    fmt.add_argument("--json", dest="format", action="store_const", const="json")
    fmt.add_argument("--tsv", dest="format", action="store_const", const="tsv")
    parser.add_argument("--home", help="HOME alternativo (padrão: o do usuário)")
    parser.add_argument("--etc-bashrc", default="/etc/bashrc")
    args = parser.parse_args(argv)

    catalog = collect(args.home, args.etc_bashrc)
    if args.format == "tsv":
        sys.stdout.write(to_tsv(catalog))
        for warning in catalog.warnings:
            print(f"aviso: {warning}", file=sys.stderr)
    else:
        json.dump(to_json(catalog), sys.stdout, ensure_ascii=False)
        sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
