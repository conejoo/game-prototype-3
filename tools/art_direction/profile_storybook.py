"""AD019 Compatibility whole-frame profiler; isolated data, fresh evidence, owned PID.

Reuses M018 process-memory counters and the weather fixture's cadence/travel method.
--smoke validates tooling only. Full acceptance always requires the unshortened run.
"""
import argparse
import ctypes
import hashlib
import importlib.util
import json
import os
import platform
import re
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("map_memory", ROOT / "tools/map_migration/profile_map.py")
memory = importlib.util.module_from_spec(spec)
spec.loader.exec_module(memory)


def manifest(project):
    files = {}
    for scope in ("game", "tools"):
        for directory, children, names in os.walk(project / scope):
            children[:] = [c for c in children if c not in (".godot", "__pycache__", ".git")]
            for child in children:
                assert not (Path(directory) / child).is_symlink(), "linked source"
            for name in names:
                path = Path(directory) / name
                if path.suffix in (".pyc", ".pyo"):
                    continue
                assert not path.is_symlink(), "linked source"
                files[path.relative_to(project).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    canonical = "".join(f"{p}\t{files[p]}\n" for p in sorted(files))
    return {"sha256": hashlib.sha256(canonical.encode()).hexdigest(), "file_count": len(files), "files": files}


def write(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def guarded(path, ancestor):
    path = path.absolute()
    assert path.is_relative_to(ancestor), "path outside task ownership"
    for part in (path, *path.parents):
        assert not part.is_symlink() and not (part.exists() and part.is_junction()), "linked path"
        if part == ancestor:
            break
    return path


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("--smoke", action="store_true")
    parser.add_argument("--project-root", type=Path, default=ROOT)
    parser.add_argument("--label", choices=("painted", "prepaint"), default="painted")
    args = parser.parse_args()
    project = args.project_root.absolute()
    if project != ROOT:
        guarded(project, ROOT / "builds/art-direction/AD019")
        assert args.label == "prepaint", "alternate root is baseline only"
    assert memory.GODOT.is_file(), "installed Godot console missing"
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S") + "-" + uuid4().hex[:8]
    output = guarded(ROOT / "docs/evidence/AD019" / (args.label + "-" + stamp), ROOT)
    output.mkdir(parents=True, exist_ok=False)
    render = output / "render"
    # Baseline engine evidence guard is relative to its own project. Store its
    # raw output there and record that exact path; never impersonate W009/R016.
    if project != ROOT:
        render = project / "docs/evidence/AD019" / stamp / "render"
    staging = guarded(ROOT / "builds/art-direction/AD019" / stamp, ROOT)
    env = os.environ.copy()
    env["APPDATA"] = str(staging / "appdata")
    env["LOCALAPPDATA"] = str(staging / "localappdata")
    env["RETURNING_FAIR_EVIDENCE_DIR"] = str(render)
    for field in ("APPDATA", "LOCALAPPDATA"):
        Path(env[field]).mkdir(parents=True, exist_ok=False)
    command = [str(memory.GODOT), "--path", str(project / "game"), "--disable-vsync", "--max-fps", "0", "--script", "res://tests/art_direction_performance_profile.gd", "--", "--save-slot=ad019-" + stamp, "--profile-output=" + str(render)]
    if args.smoke:
        command += ["--profile-warmup=1", "--profile-duration=2", "--profile-runs=1"]
    hardware = subprocess.run(["powershell.exe", "-NoProfile", "-Command", "$taskOs = Get-CimInstance Win32_OperatingSystem; $taskCpu = Get-CimInstance Win32_Processor; $taskGpu = Get-CimInstance Win32_VideoController; [ordered]@{os=$taskOs.Caption;version=$taskOs.Version;cpu=@($taskCpu.Name);ram_bytes=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory;gpu=@($taskGpu | Select-Object Name,DriverVersion)} | ConvertTo-Json -Depth 5"], capture_output=True, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
    write(output / "hardware-command.json", {"exit_code": hardware.returncode, "stderr": hardware.stderr})
    if hardware.returncode:
        raise RuntimeError("hardware query failed; retained evidence " + str(output))
    (output / "hardware.json").write_text(hardware.stdout, encoding="utf-8")
    before = manifest(project)
    write(output / "source-before.json", before)
    write(output / "launch.json", {"task": "AD019", "label": args.label, "argv": command, "cwd": str(project), "render_output": str(render), "APPDATA": env["APPDATA"], "LOCALAPPDATA": env["LOCALAPPDATA"], "smoke": args.smoke, "platform": platform.platform()})
    print("AD019_PROFILE=" + str(output), flush=True)
    started = time.monotonic()
    samples, engine_pid, handle = [], None, None
    stage, last_stage, failure = "startup", "", None
    with (output / "runtime.log").open("w", encoding="utf-8") as log, (output / "working-set.csv").open("w", encoding="utf-8") as csv:
        process = subprocess.Popen(command, cwd=project, env=env, stdout=log, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
        csv.write("elapsed_seconds,stage,working_set_bytes,peak_working_set_bytes,pagefile_bytes\n")
        try:
            while process.poll() is None:
                try:
                    record = json.loads((render / "stage.json").read_text(encoding="utf-8"))
                    stage = record["stage"]
                    if engine_pid is None:
                        engine_pid = int(record["pid"])
                        handle = memory.kernel.OpenProcess(0x0400 | 0x0010, False, engine_pid)
                        if not handle:
                            raise ctypes.WinError(ctypes.get_last_error())
                    assert engine_pid == int(record["pid"]), "engine PID changed"
                except (FileNotFoundError, json.JSONDecodeError):
                    pass
                counters = memory.MemoryCounters()
                counters.cb = ctypes.sizeof(counters)
                if handle:
                    if not memory.psapi.GetProcessMemoryInfo(handle, ctypes.byref(counters), counters.cb):
                        if process.poll() is None:
                            raise ctypes.WinError(ctypes.get_last_error())
                    else:
                        row = {"seconds": time.monotonic() - started, "stage": stage, "working_set_bytes": counters.WorkingSetSize, "peak_working_set_bytes": counters.PeakWorkingSetSize, "pagefile_bytes": counters.PagefileUsage}
                        samples.append(row)
                        csv.write(f"{row['seconds']:.6f},{stage},{counters.WorkingSetSize},{counters.PeakWorkingSetSize},{counters.PagefileUsage}\n")
                        csv.flush()
                if stage != last_stage:
                    print("AD019 " + args.label + " " + stage, flush=True)
                    last_stage = stage
                diagnostics = (output / "runtime.log").read_text(encoding="utf-8")
                if re.search(r"(?m)^\s*(SCRIPT ERROR:|ERROR:|WARNING:)", diagnostics):
                    raise RuntimeError("Runtime diagnostic; see retained log")
                if time.monotonic() - started > (240 if args.smoke else 2100):
                    raise TimeoutError("AD019 bounded profiler deadline exceeded")
                time.sleep(.25)
        except BaseException as error:
            failure = str(error)
        finally:
            if process.poll() is None:
                subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"], capture_output=True, creationflags=subprocess.CREATE_NO_WINDOW)
            if handle:
                memory.kernel.CloseHandle(handle)
    code = process.wait()
    diagnostics = [line for line in (output / "runtime.log").read_text(encoding="utf-8").splitlines() if re.match(r"\s*(SCRIPT ERROR:|ERROR:|WARNING:)", line)]
    baseline = [x["working_set_bytes"] for x in samples if x["stage"] == "checkpoint-baseline"]
    final = [x["working_set_bytes"] for x in samples if x["stage"] == "checkpoint-final"]
    peak = max((x["peak_working_set_bytes"] for x in samples), default=0)
    growth = max(final) - max(baseline) if baseline and final else None
    after = manifest(project)
    write(output / "source-after.json", after)
    result = {"task": "AD019", "label": args.label, "launcher_pid": process.pid, "engine_pid": engine_pid, "engine_exit": code, "runtime_errors": diagnostics, "failure": failure, "source_changed": before != after, "peak_working_set_bytes": peak, "baseline_working_set_bytes": baseline, "final_working_set_bytes": final, "growth_bytes": growth, "memory_pass": bool(peak and peak <= 2 * 1024**3 and growth is not None and growth <= 64 * 1024**2), "sample_period_seconds": .25, "elapsed_seconds": time.monotonic() - started, "smoke": args.smoke, "render_output": str(render), "owned_launcher_exited": process.poll() is not None}
    write(output / "process-results.json", result)
    if (render / "report.json").exists():
        report = json.loads((render / "report.json").read_text(encoding="utf-8"))
        write(output / "capture-index.json", {"views": report.get("captures", []), "failures": report.get("failures", [])})
    print(json.dumps(result), flush=True)
    return 0 if code == 0 and not failure and not diagnostics and not result["source_changed"] and result["memory_pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
