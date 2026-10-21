import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("installer", Path(__file__).parents[1] / "scripts/install.py")
installer = importlib.util.module_from_spec(spec)
spec.loader.exec_module(installer)


class InstallerTests(unittest.TestCase):
    def test_dry_run_writes_nothing(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / "config"
            installer.install(["QuietClock"], home, dry_run=True)
            self.assertFalse(home.exists())

    def test_link_is_idempotent(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp)
            installer.install(["QuietClock"], home)
            link = home / "DankMaterialShell/plugins/QuietClock"
            before = link.lstat().st_ino
            installer.install(["QuietClock"], home)
            self.assertEqual(link.lstat().st_ino, before)

    def test_existing_install_requires_explicit_replacement_and_survives_in_backup(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp)
            target = home / "DankMaterialShell/plugins/QuietClock"
            target.mkdir(parents=True)
            (target / "custom.txt").write_text("my changes")
            with self.assertRaises(FileExistsError):
                installer.install(["QuietClock"], home)
            installer.install(["QuietClock"], home, replace=True)
            self.assertTrue(target.is_symlink())
            saved = list((home / "DankMaterialShell/backups").glob("*/QuietClock/custom.txt"))
            self.assertEqual(len(saved), 1)
            self.assertEqual(saved[0].read_text(), "my changes")

    def test_conflict_is_detected_before_any_links_are_written(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp)
            target = home / "DankMaterialShell/plugins/NordMediaCard"
            target.mkdir(parents=True)
            with self.assertRaises(FileExistsError):
                installer.install(["QuietClock", "NordMediaCard"], home)
            self.assertFalse((target.parent / "QuietClock").exists())
