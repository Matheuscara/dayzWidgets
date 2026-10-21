import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location(
    "command_catalog",
    Path(__file__).parents[1] / "plugins" / "CommandShelf" / "commands.py",
)
catalog = importlib.util.module_from_spec(spec)
spec.loader.exec_module(catalog)


class CommandCatalogTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home"
        self.home.mkdir()
        self.etc_bashrc = Path(self.temp.name) / "etc-bashrc"
        self.marker = Path(self.temp.name) / "executed"

    def file(self, relative, content, mode=None):
        path = self.home / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        if mode is not None:
            path.chmod(mode)
        return path

    def collect(self):
        return catalog.collect(self.home, self.etc_bashrc)

    def by_name(self, result):
        return {c["name"]: c for c in result.commands}

    def test_missing_optional_sources_only_yield_desktop_shortcuts(self):
        result = self.collect()
        self.assertEqual({c["category"] for c in result.commands}, {"desktop"})
        self.assertEqual(result.warnings, [])

    def test_bashrc_categories_descriptions_and_nested_declarations(self):
        self.file(".bashrc", f"""\
touch {self.marker}
#: Aplica a config
alias nixrebuild='sudo nixos-rebuild switch'
#: Mostra a conta
alias ghwho='gh auth status 2>&1 | sed -n "s/x/$(touch {self.marker})/p"'
#: Primeira linha
#: segunda linha
deploy() {{
alias inner='echo nested'
helper() {{ echo nested; }}
}}
nixup() {{ sudo nixos-rebuild switch --upgrade; }}
alias -- dashed='ls -l' second="echo 2"
""")
        commands = self.by_name(self.collect())
        self.assertNotIn("inner", commands)
        self.assertNotIn("helper", commands)
        self.assertEqual(commands["nixrebuild"]["category"], "nix")
        self.assertEqual(commands["nixrebuild"]["description"], "Aplica a config")
        self.assertEqual(commands["nixup"]["category"], "nix")
        self.assertEqual(commands["nixup"]["detail"], "sudo nixos-rebuild switch --upgrade")
        self.assertEqual(commands["ghwho"]["category"], "shell")
        self.assertIn("$(touch", commands["ghwho"]["detail"])
        self.assertEqual(commands["deploy"]["kind"], "function")
        self.assertEqual(commands["deploy"]["detail"], "função")
        self.assertEqual(commands["deploy"]["description"], "Primeira linha segunda linha")
        self.assertEqual(commands["dashed"]["detail"], "ls -l")
        self.assertEqual(commands["second"]["detail"], "echo 2")
        self.assertEqual(commands["nixrebuild"]["command"], "nixrebuild")
        self.assertFalse(self.marker.exists())

    def test_unbalanced_alias_is_reported_not_guessed(self):
        self.file(".bashrc", "alias broken='echo oops\nalias ok='true'\n")
        result = self.collect()
        names = [c["name"] for c in result.commands]
        self.assertNotIn("broken", names)
        self.assertIn("ok", names)
        self.assertEqual(len(result.warnings), 1)

    def test_only_regular_shebang_scripts_are_listed_and_never_run(self):
        script = self.file(".local/bin/backup", f"#!/bin/sh\ntouch {self.marker}\n#: Faz backup\n", 0o755)
        self.file(".local/bin/binary", "\x7fELF....", 0o755)
        self.file(".local/bin/.hidden", "#!/bin/sh\n", 0o755)
        (self.home / ".local/bin/link").symlink_to(script)
        commands = self.by_name(self.collect())
        scripts = [n for n, c in commands.items() if c["category"] == "scripts"]
        self.assertEqual(scripts, ["backup"])
        self.assertEqual(commands["backup"]["description"], "Faz backup")
        self.assertEqual(commands["backup"]["command"], "backup")
        self.assertFalse(self.marker.exists())

    def test_system_aliases_go_to_nix_without_functions(self):
        self.etc_bashrc.write_text("alias -- l='ls -alh'\nsysfn() { echo x; }\n")
        commands = self.by_name(self.collect())
        self.assertEqual(commands["l"]["category"], "nix")
        self.assertEqual(commands["l"]["kind"], "system-alias")
        self.assertNotIn("sysfn", commands)

    def test_ssh_concrete_hosts_patterns_and_tunnels(self):
        self.file(".ssh/config", """\
Include ~/.ssh/extra
#: Servidores
Host alpha beta *.corp !gamma web?
  HostName 192.168.1.5
  User admin

Host *
  ForwardAgent no

#: Túnel
Host tunnel
    HostName box.ts.net
    LocalForward 3080 127.0.0.1:3081

Match host delta
  User nobody
Host 'odd name'
""")
        commands = self.by_name(self.collect())
        ssh = {n: c for n, c in commands.items() if c["category"] == "ssh"}
        self.assertEqual(set(ssh), {"alpha", "beta", "tunnel", "odd name"})
        self.assertEqual(ssh["alpha"]["command"], "ssh alpha")
        self.assertEqual(ssh["beta"]["detail"], "admin@192.168.1.5")
        self.assertEqual(ssh["beta"]["description"], "Servidores")
        self.assertEqual(ssh["tunnel"]["description"], "Túnel · túnel localhost:3080 → 127.0.0.1:3081")
        self.assertEqual(ssh["odd name"]["command"], "ssh 'odd name'")
        self.assertEqual(ssh["odd name"]["description"], "")



if __name__ == "__main__":
    unittest.main()
