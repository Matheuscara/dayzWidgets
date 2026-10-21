#!/usr/bin/env python3
"""Instala os plugins selecionados por links, sem alterar as preferências do DMS."""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]


def install(names, config_home, *, dry_run=False, replace=False):
    target = config_home / "DankMaterialShell/plugins"
    backup = config_home / "DankMaterialShell/backups" / datetime.now(timezone.utc).strftime("dayz-%Y%m%dT%H%M%S%fZ")
    conflicts = [target / name for name in names if ((target / name).exists() or (target / name).is_symlink()) and not ((target / name).is_symlink() and (target / name).resolve() == ROOT / "plugins" / name)]
    if conflicts and not replace:
        raise FileExistsError("Instalações existentes: " + ", ".join(map(str, conflicts)) + "; use --replace para guardar backup e substituir")
    for name in names:
        source = ROOT / "plugins" / name
        destination = target / name
        if destination.is_symlink() and destination.resolve() == source:
            print(f"Já instalado: {name}")
            continue
        if destination.exists() or destination.is_symlink():
            if not replace:
                raise FileExistsError(f"{destination} já existe; use --replace para guardar backup e substituir")
            print(f"Backup: {destination} -> {backup / name}")
            if not dry_run:
                backup.mkdir(parents=True, exist_ok=True, mode=0o700)
                shutil.move(str(destination), str(backup / name))
        print(f"{'Prévia' if dry_run else 'Instalar'}: {destination} -> {source}")
        if not dry_run:
            target.mkdir(parents=True, exist_ok=True)
            destination.symlink_to(source)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--plugin", action="append", default=[])
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--replace", action="store_true")
    parser.add_argument("--config-home", type=Path, default=Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")))
    args = parser.parse_args()
    entries = json.loads((ROOT / "plugins.json").read_text())["plugins"]
    known = {entry["directory"] for entry in entries}
    if args.list:
        for entry in entries:
            print(f"{entry['directory']:20} {entry['id']:22} {entry['kind']} · {entry['license']}")
        return
    names = sorted(known) if args.all else list(dict.fromkeys(args.plugin))
    if not names:
        parser.error("escolha --all, --plugin NOME ou --list")
    if set(names) - known:
        parser.error("plugin desconhecido: " + ", ".join(sorted(set(names) - known)))
    try:
        install(names, args.config_home.expanduser(), dry_run=args.dry_run, replace=args.replace)
    except FileExistsError as error:
        parser.exit(1, str(error) + "\n")
    print("Reinicie o DMS quando conveniente e habilite os plugins em Configurações → Plugins.")
    print("Widgets desktop precisam de instância; widgets da barra precisam ser adicionados à barra.")


if __name__ == "__main__":
    main()
