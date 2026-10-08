"""F010 local exports, retained old packages, pack audit and isolated startup."""
import hashlib
import json
import os
import re
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[2]
GODOT = Path("D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe")


def main():
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S") + "-" + uuid4().hex[:8]
    evidence = ROOT / "docs/evidence/F010" / ("packages-" + stamp)
    staging = ROOT / "builds/foraging-items-backpack/F010" / stamp
    evidence.mkdir(parents=True, exist_ok=False)
    staging.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    for key, leaf in [("APPDATA", "appdata"), ("LOCALAPPDATA", "localappdata")]:
        env[key] = str(staging / leaf)
        Path(env[key]).mkdir()
    result = {"cwd":str(ROOT), "staging":str(staging), "APPDATA":env["APPDATA"], "LOCALAPPDATA":env["LOCALAPPDATA"], "cases":[], "packages":{}, "preserved":{}}

    def publish():
        (evidence / "results.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    def run(label, command, cwd, editor=False):
        log = evidence / (label + ".log")
        row = {"label":label, "argv":list(map(str, command)), "cwd":str(cwd), "log":str(log)}
        result["cases"].append(row)
        publish()
        with log.open("w", encoding="utf-8") as stream:
            process = subprocess.Popen(command, cwd=cwd, env=env, stdout=stream, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
            row["launcher_pid"] = process.pid
            publish()
            try:
                row["exit_code"] = process.wait(timeout=180)
            except subprocess.TimeoutExpired:
                subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"], capture_output=True, creationflags=subprocess.CREATE_NO_WINDOW)
                row["timed_out"] = True
                publish()
                raise
        text = log.read_text(encoding="utf-8")
        errors = [line for line in text.splitlines() if re.match(r"\s*(?:SCRIPT ERROR:|ERROR:|WARNING:)", line)]
        row["allowed_diagnostics"] = [line for line in errors if editor and line.strip() == "ERROR: .NET Sdk not found. The required version is '10.0.9'."]
        row["errors"] = [line for line in errors if line not in row["allowed_diagnostics"]]
        row["arrival"] = "P004: arrived prototype-alderwake/alderwake-start; party=2" in text
        publish()
        print(label, row["exit_code"], row["errors"], flush=True)
        if row["exit_code"] or row["errors"]:
            raise RuntimeError(label)
        return row

    print("F010_PACKAGES=" + str(evidence), flush=True)
    for mode, folder, filename, preset, flag in [
        ("validation", "windows-validation", "ReturningFairValidation.exe", "Windows Validation", "--export-debug"),
        ("release", "windows", "ReturningFair.exe", "Windows Desktop", "--export-release"),
    ]:
        old = ROOT / "builds" / folder
        archive = staging / "previous-packages" / folder
        shutil.copytree(old, archive)
        result["preserved"][folder] = {p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in archive.iterdir() if p.is_file()}
        target = staging / folder
        target.mkdir()
        exe = target / filename
        run("export-" + mode, [GODOT, "--headless", "--path", ROOT / "game", flag, preset, exe], ROOT, True)
        audit = evidence / (mode + "-pack-audit.json")
        run("audit-" + mode, [GODOT, "--headless", "--path", target, "--main-pack", exe.with_suffix(".pck"), "--script", ROOT / "tools/foraging_items/package_audit.gd", "--", "--audit-mode=" + mode, "--audit-output=" + str(audit)], target)
        outside_cwd = Path(os.environ["TEMP"]).resolve()
        if outside_cwd.is_relative_to(ROOT):
            raise RuntimeError("Standalone startup cwd must be outside checkout")
        row = run("startup-" + mode, [exe, "--headless", "--quit-after", "180", "--verbose", "--", "--environment-review=f010-ignored" if mode == "release" else "--save-slot=f010-package"], outside_cwd)
        if not row["arrival"]:
            raise RuntimeError("Standalone arrival missing: " + mode)
        result["packages"][mode] = {p.name:{"bytes":p.stat().st_size, "sha256":hashlib.sha256(p.read_bytes()).hexdigest()} for p in target.iterdir() if p.is_file()}
        # Promotion is reversible: archived originals include override.cfg unchanged.
        for path in target.iterdir():
            shutil.copy2(path, old / path.name)
        result["packages"][mode]["installed_directory"] = str(old)
        publish()
    result["status"] = "passed"
    publish()


if __name__ == "__main__":
    main()
