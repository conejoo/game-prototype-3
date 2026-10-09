"""FS008 isolated fresh exports/audits/startups, exact archives before promotion.

Reuse the established delivery hashing implementation; no gameplay mutation.
Promotion is explicit and only follows all eight clean package cases.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.social_migration.build_packages import GODOT, hashes, production_hashes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--promote", action="store_true")
    args = parser.parse_args()
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S") + "-" + uuid4().hex[:8]
    evidence = ROOT / "docs/evidence/FS008" / ("packages-" + stamp)
    staging = ROOT / "builds/fishing/FS008" / stamp
    evidence.mkdir(parents=True, exist_ok=False)
    staging.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    result = {"task": "FS008", "status": "running", "cwd": str(ROOT),
              "staging": str(staging), "cases": [], "packages": {}, "preserved": {},
              "promoted": False, "native_acceptance": False}

    def publish():
        (evidence / "results.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

    def run(label, command, cwd, editor=False):
        if production_hashes() != result["production_before"]:
            raise RuntimeError("Production changed before " + label)
        group = staging / "isolation" / label
        for key, leaf in (("APPDATA", "appdata"), ("LOCALAPPDATA", "localappdata")):
            env[key] = str(group / leaf)
            Path(env[key]).mkdir(parents=True)
        row = {"label": label, "argv": list(map(str, command)), "cwd": str(cwd),
               "log": str(evidence / (label + ".log")),
               "APPDATA": env["APPDATA"], "LOCALAPPDATA": env["LOCALAPPDATA"]}
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

    print("FS008_PACKAGES=" + str(evidence), flush=True)
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
            ("validation", "windows-validation", "ReturningFairValidation.exe", "Windows Validation", "--export-debug"),
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
            for audit, script in (("social", "tools/social_migration/package_audit.gd"), ("fishing", "tools/fishing/package_audit.gd")):
                run("audit-" + audit + "-" + mode, [GODOT, "--headless", "--path", target,
                    "--main-pack", exe.with_suffix(".pck"), "--script", ROOT / script, "--",
                    "--audit-mode=" + mode, "--audit-output=" + str(evidence / (mode + "-" + audit + "-audit.json"))], target)
            row = run("startup-" + mode, [exe, "--headless", "--quit-after", "180", "--verbose"], outside)
            if not row["arrival"]: raise RuntimeError("Standalone arrival absent: " + mode)
            result["packages"][mode] = {"path": str(target), "files": hashes(target), "preset": preset}
            publish()
        if args.promote:
            for mode, folder in (("validation", "windows-validation"), ("release", "windows")):
                previous = ROOT / "builds" / folder
                if hashes(previous) != result["preserved"][folder]["files"]:
                    raise RuntimeError("Previous package changed before promotion")
                target = Path(result["packages"][mode]["path"])
                for path in target.iterdir():
                    if path.is_file(): shutil.copy2(path, previous / path.name)
                current = hashes(previous)
                for name, expected in result["packages"][mode]["files"].items():
                    if current[name] != expected: raise RuntimeError("Promotion hash differs")
                old_override = result["preserved"][folder]["files"].get("override.cfg")
                if current.get("override.cfg") != old_override:
                    raise RuntimeError("Existing override identity changed")
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
