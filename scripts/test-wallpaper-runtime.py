#!/usr/bin/env python3
"""Testa o timer real do plugin com SessionData isolado, sem tocar no desktop."""
from pathlib import Path
import json
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    quickshell = shutil.which("quickshell")
    if not quickshell:
        raise SystemExit("Requer Quickshell para testar o timer nativo.")
    with tempfile.TemporaryDirectory(prefix="dayz-wallpaper-runtime-") as directory:
        root = Path(directory)
        for folder in ["Common", "Services", "Modules/Plugins", "images/Chosen", "images/Other"]:
            (root / folder).mkdir(parents=True)
        for name in ["Chosen/a.png", "Chosen/b.png", "Other/c.png"]:
            (root / "images" / name).write_bytes(b"index fixture")
        for name in ["DayzWallpapers.qml", "wallpapers.py"]:
            shutil.copy2(ROOT / "plugins/DayzWallpapers" / name, root / name)
        (root / "Modules/Plugins/PluginComponent.qml").write_text('''import QtQuick
Item { property var pluginData: ({}); property string pluginId; property var pluginService }
''')
        (root / "WallpaperPicker.qml").write_text('''import QtQuick
Item { required property var controller; property int previewState: -1; function openSchedule() {} }
''')
        (root / "Common/qmldir").write_text("module qs.Common\nsingleton SessionData 1.0 SessionData.qml\n")
        (root / "Common/SessionData.qml").write_text('''pragma Singleton
import QtQuick
QtObject {
 property bool perMonitorWallpaper: false
 property string wallpaperPath: INITIAL
 property int changes: 0
 property bool wallpaperCyclingEnabled: true
 function setWallpaperCyclingEnabled(value) { wallpaperCyclingEnabled = value; }
 function setWallpaper(path) { wallpaperPath = path; changes++; }
 function getMonitorWallpaper(name) { return wallpaperPath; }
 function setMonitorWallpaper(name, path) { setWallpaper(path); }
}'''.replace("INITIAL", json.dumps(str(root / "images/Chosen/a.png"))))
        (root / "Services/qmldir").write_text("module qs.Services\nsingleton CompositorService 1.0 CompositorService.qml\n")
        (root / "Services/CompositorService.qml").write_text('''pragma Singleton
import QtQuick
QtObject { function getFocusedScreen() { return null; } }
''')
        (root / "shell.qml").write_text('''import QtQuick
import Quickshell
import qs.Common
Scope {
 id: test
 property real started: 0
 property bool failed: false
 function fail(reason) { failed = true; console.error("DAYZ_RUNTIME_FAIL", reason); Qt.quit(); }
 QtObject {
  id: store
  function savePluginData(id, key, value) {
   const data = Object.assign({}, daemon.pluginData);
   data[key] = value;
   daemon.pluginData = data;
  }
 }
 DayzWallpapers {
  id: daemon
  pluginId: "dayzWallpapers"
  pluginService: store
  pluginData: ({directory: ROOT_DIR})
 }
 Timer {
  interval: 50; repeat: true; running: true
  onTriggered: {
   if (daemon.loading || daemon.images.length !== 3) return;
   stop();
   if (daemon.rotationEnabled) { test.fail("timer ativo por padrão"); return; }
   if (daemon.configureRotation(true, 1.5, "Chosen", "random")) { test.fail("intervalo fracionário aceito"); return; }
   if (daemon.configureRotation(true, 1, "Missing", "random")) { test.fail("categoria ausente aceita"); return; }
   daemon.selectedCategory = "Other";
   if (!daemon.configureRotation(true, 1, "Chosen", "sequential")) { test.fail("configuração válida recusada"); return; }
   if (SessionData.wallpaperCyclingEnabled) { test.fail("agendamento nativo concorrente ativo"); return; }
   test.started = Date.now();
   daemon.close();
  }
 }
 Timer {
  interval: 200; repeat: true; running: test.started > 0
  onTriggered: {
   if (SessionData.changes === 0) return;
   if (daemon.opened) { test.fail("seletor precisa ficar fechado"); return; }
   if (!SessionData.wallpaperPath.endsWith("/Chosen/b.png")) { test.fail("categoria ou ordem incorreta"); return; }
   if (Date.now() - test.started < 59000) { test.fail("troca antes do intervalo"); return; }
   daemon.save("rotationEnabled", false);
   if (daemon.rotationEnabled) { test.fail("pausa não persistiu"); return; }
   if (SessionData.changes !== 1) { test.fail("houve trocas extras"); return; }
   console.log("DAYZ_RUNTIME_PASS: timer de 60 s, seletor fechado, categoria independente, sequência e pausa");
   Qt.quit();
  }
 }
 Timer { interval: 75000; running:true; onTriggered: test.fail("timeout") }
}'''.replace("ROOT_DIR", json.dumps(str(root / "images"))))
        env = os.environ.copy()
        env.update(QT_QPA_PLATFORM="offscreen", QT_QUICK_BACKEND="software", QT_LOGGING_RULES="*.debug=false;qml.debug=true", XDG_CONFIG_HOME=str(root / "config"), XDG_CACHE_HOME=str(root / "cache"))
        env.pop("WAYLAND_DISPLAY", None)
        result = subprocess.run([quickshell, "--path", str(root), "--no-color"], env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=90)
        lines = [line for line in result.stdout.splitlines() if "DAYZ_RUNTIME_" in line or "ERROR" in line]
        print("\n".join(lines))
        if result.returncode or "DAYZ_RUNTIME_PASS" not in result.stdout or "DAYZ_RUNTIME_FAIL" in result.stdout:
            raise SystemExit("Falha no teste nativo isolado; o desktop real não foi alterado.")


if __name__ == "__main__":
    main()
