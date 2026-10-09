"""G009 fresh local packages, exact archives, pack audit and isolated startup.

No promotion until both packages pass. Existing packages are copied and hashed;
normal user data is never read. Each invocation owns unique staging/evidence.
"""
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


def production_hashes():
    return {name: value for name, value in hashes(ROOT / "game").items()
            if not name.startswith(".godot/") and "__pycache__/" not in name}


def hashes(folder):
    return {str(p.relative_to(folder)).replace("\\", "/"): {
        "bytes": p.stat().st_size, "sha256": hashlib.sha256(p.read_bytes()).hexdigest()
    } for p in sorted(folder.rglob("*")) if p.is_file()}


def main():
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S") + "-" + uuid4().hex[:8]
    evidence = ROOT / "docs/evidence/G009" / ("packages-" + stamp)
    staging = ROOT / "builds/gifts-friendship-people-journal/G009" / stamp
    evidence.mkdir(parents=True, exist_ok=False)
    staging.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    for key, leaf in (("APPDATA", "appdata"), ("LOCALAPPDATA", "localappdata")):
        env[key] = str(staging / leaf)
        Path(env[key]).mkdir()
    result = {"task": "G009", "status": "running", "cwd": str(ROOT), "staging": str(staging),
              "APPDATA": env["APPDATA"], "LOCALAPPDATA": env["LOCALAPPDATA"], "cases": [],
              "packages": {}, "preserved": {}, "promoted": False}

    def publish():
        (evidence / "results.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    def run(label, command, cwd, editor=False):
        if production_hashes() != result["production_before"]:
            raise RuntimeError("Production changed before " + label)
        row = {"label": label, "argv": list(map(str, command)), "cwd": str(cwd),
               "log": str(evidence / (label + ".log"))}
        result["cases"].append(row)
        publish()
        with Path(row["log"]).open("w", encoding="utf-8") as stream:
            process = subprocess.Popen(command, cwd=cwd, env=env, stdout=stream,
                                       stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
            row["launcher_pid"] = process.pid
            publish()
            try:
                row["exit_code"] = process.wait(timeout=180)
            except subprocess.TimeoutExpired:
                subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"],
                               capture_output=True, creationflags=subprocess.CREATE_NO_WINDOW)
                row["timed_out"] = True
                publish()
                raise
        output = Path(row["log"]).read_text(encoding="utf-8")
        diagnostics = [s for s in output.splitlines() if re.match(r"\s*(SCRIPT ERROR:|ERROR:|WARNING:)", s)]
        row["allowed_diagnostics"] = [s for s in diagnostics if editor and s.strip() ==
                                      "ERROR: .NET Sdk not found. The required version is '10.0.9'."]
        row["errors"] = [s for s in diagnostics if s not in row["allowed_diagnostics"]]
        row["arrival"] = "P004: arrived prototype-alderwake/alderwake-start; party=2" in output
        publish()
        print(label, row["exit_code"], row["errors"], flush=True)
        if row["exit_code"] or row["errors"]:
            raise RuntimeError(label)
        if production_hashes() != result["production_before"]:
            raise RuntimeError("Production changed during " + label)
        return row

    print("G009_PACKAGES=" + str(evidence), flush=True)
    try:
        if not GODOT.is_file(): raise RuntimeError("Installed Godot missing")
        result["production_before"] = production_hashes()
        templates = ROOT / "builds/p014/templates"
        if (templates / "version.txt").read_text().strip() != "4.7.2.stable":
            raise RuntimeError("Template version differs")
        result["templates"] = hashes(templates)
        outside = Path(os.environ["TEMP"]).resolve()
        if outside.is_relative_to(ROOT): raise RuntimeError("Standalone cwd is inside checkout")
        for mode, folder, filename, preset, flag in (
            ("validation", "windows-validation", "ReturningFairValidation.exe", "Windows Desktop", "--export-debug"),
            ("release", "windows", "ReturningFair.exe", "Windows Desktop", "--export-release"),
        ):
            previous = ROOT / "builds" / folder
            if previous.is_symlink() or previous.is_junction() or any(p.is_symlink() or p.is_junction() for p in previous.rglob("*")):
                raise RuntimeError("Package reparse point refused")
            archive = staging / "previous-packages" / folder
            original = hashes(previous)
            shutil.copytree(previous, archive)
            if hashes(archive) != original: raise RuntimeError("Previous package archive differs")
            result["preserved"][folder] = {"path": str(archive), "files": original}
            target = staging / folder
            target.mkdir()
            exe = target / filename
            run("export-" + mode, [GODOT, "--headless", "--path", ROOT / "game", flag, preset, exe], ROOT, True)
            run("audit-" + mode, [GODOT, "--headless", "--path", target, "--main-pack", exe.with_suffix(".pck"),
                "--script", ROOT / "tools/social_migration/package_audit.gd", "--", "--audit-mode=" + mode,
                "--audit-output=" + str(evidence / (mode + "-pack-audit.json"))], target)
            row = run("startup-" + mode, [exe, "--headless", "--quit-after", "180", "--verbose"], outside)
            if not row["arrival"]: raise RuntimeError("Standalone arrival absent: " + mode)
            result["packages"][mode] = {"path": str(target), "files": hashes(target)}
            publish()
        # Existing override stays intact; launcher additionally isolates APPDATA.
        for mode, folder in (("validation", "windows-validation"), ("release", "windows")):
            previous = ROOT / "builds" / folder
            if hashes(previous) != result["preserved"][folder]["files"]:
                raise RuntimeError("Previous package changed before promotion")
            target = Path(result["packages"][mode]["path"])
            for path in target.iterdir():
                if path.is_file(): shutil.copy2(path, previous / path.name)
            for name, expected in result["packages"][mode]["files"].items():
                if hashes(previous)[name] != expected: raise RuntimeError("Promotion hash differs")
        result["promoted"] = True
        result["production_after"] = production_hashes()
        result["status"] = "passed"
    except Exception as error:
        result["status"] = "failed"
        result["error"] = str(error)
        raise
    finally:
        publish()


if __name__ == "__main__": main()
