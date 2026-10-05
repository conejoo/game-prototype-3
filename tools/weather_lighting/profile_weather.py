"""W009 rendered M018 method with fresh evidence, isolated saves and PID memory."""
import argparse
import ctypes
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
spec = importlib.util.spec_from_file_location("map_profile", ROOT / "tools/map_migration/profile_map.py")
memory = importlib.util.module_from_spec(spec)
spec.loader.exec_module(memory)


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("--smoke", action="store_true")
    parser.add_argument("--storm-only", action="store_true", help="Focused retest: all four storm/night views, original duration/run gates")
    parser.add_argument("--ford-only", action="store_true", help="Focused remaining ford-view retest; requires --storm-only")
    args = parser.parse_args()
    if args.ford_only and not args.storm_only:
        parser.error("--ford-only requires --storm-only")
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S") + "-" + uuid4().hex[:8]
    output = ROOT / "docs/evidence/W009" / ("profile-" + stamp)
    output.mkdir(parents=True, exist_ok=False)
    render = output / "render"  # engine guard requires a fresh leaf
    staging = ROOT / "builds/weather-lighting/W009" / stamp
    env = os.environ.copy()
    env["APPDATA"] = str(staging / "appdata")
    env["LOCALAPPDATA"] = str(staging / "localappdata")
    env["RETURNING_FAIR_EVIDENCE_DIR"] = str(render)
    for field in ("APPDATA", "LOCALAPPDATA"):
        Path(env[field]).mkdir(parents=True, exist_ok=False)
    command = [str(memory.GODOT), "--path", str(ROOT / "game"), "--disable-vsync", "--max-fps", "0", "--script", "res://tests/weather_performance_profile.gd", "--", "--save-slot=w009-profile", "--profile-output=" + str(render)]
    if args.smoke:
        command += ["--profile-warmup=1", "--profile-duration=2", "--profile-runs=1"]
    if args.storm_only:
        command += ["--profile-storm-only"]
    if args.ford_only:
        command += ["--profile-ford-only"]
    hardware_command = ["powershell.exe", "-NoProfile", "-Command", "$os = Get-CimInstance Win32_OperatingSystem; $cpu = Get-CimInstance Win32_Processor; $gpu = Get-CimInstance Win32_VideoController; [ordered]@{os=$os.Caption;version=$os.Version;cpu=@($cpu.Name);ram_bytes=(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory;gpu=@($gpu | Select-Object Name,DriverVersion)} | ConvertTo-Json -Depth 5"]
    hardware = subprocess.run(hardware_command, capture_output=True, text=True, check=True, creationflags=subprocess.CREATE_NO_WINDOW)
    (output / "hardware.json").write_text(hardware.stdout, encoding="utf-8")
    (output / "launch.json").write_text(json.dumps({"argv":command, "cwd":str(ROOT), "APPDATA":env["APPDATA"], "LOCALAPPDATA":env["LOCALAPPDATA"], "smoke":args.smoke, "platform":platform.platform()}, indent=2) + "\n", encoding="utf-8")
    print("W009_PROFILE=" + str(output), flush=True)
    started = time.monotonic()
    samples = []
    handle = None
    engine_pid = None
    stage = "startup"
    last_stage = ""
    failure = None
    with (output / "runtime.log").open("w", encoding="utf-8") as log, (output / "working-set.csv").open("w", encoding="utf-8") as csv:
        process = subprocess.Popen(command, cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
        csv.write("elapsed_seconds,stage,working_set_bytes,peak_working_set_bytes,pagefile_bytes\n")
        try:
            while process.poll() is None:
                try:
                    record = json.loads((render / "stage.json").read_text(encoding="utf-8"))
                    stage = record["stage"]
                    if engine_pid is None:
                        engine_pid = record["pid"]
                        handle = memory.kernel.OpenProcess(0x0400 | 0x0010, False, engine_pid)
                        if not handle:
                            raise ctypes.WinError(ctypes.get_last_error())
                except (FileNotFoundError, json.JSONDecodeError):
                    pass
                counters = memory.MemoryCounters()
                counters.cb = ctypes.sizeof(counters)
                if handle and memory.psapi.GetProcessMemoryInfo(handle, ctypes.byref(counters), counters.cb):
                    row = {"seconds":time.monotonic()-started, "stage":stage, "working_set_bytes":counters.WorkingSetSize, "peak_working_set_bytes":counters.PeakWorkingSetSize, "pagefile_bytes":counters.PagefileUsage}
                    samples.append(row)
                    csv.write(f"{row['seconds']:.6f},{stage},{counters.WorkingSetSize},{counters.PeakWorkingSetSize},{counters.PagefileUsage}\n")
                    csv.flush()
                if stage != last_stage:
                    print("W009 " + stage, flush=True)
                    last_stage = stage
                diagnostics = (output / "runtime.log").read_text(encoding="utf-8")
                if re.search(r"(?m)^\s*(SCRIPT ERROR:|ERROR:|WARNING:)", diagnostics):
                    raise RuntimeError("Runtime diagnostic; see retained log")
                if time.monotonic() - started > (240 if args.smoke else 2100):
                    raise TimeoutError("W009 bounded profiler deadline exceeded")
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
    growth = max(final)-max(baseline) if baseline and final else None
    result = {"launcher_pid":process.pid, "engine_pid":engine_pid, "engine_exit":code, "runtime_errors":diagnostics, "failure":failure, "peak_working_set_bytes":peak, "baseline_working_set_bytes":baseline, "final_working_set_bytes":final, "growth_bytes":growth, "memory_pass":bool(peak and peak <= 2*1024**3 and growth is not None and growth <= 64*1024**2), "sample_period_seconds":.25, "elapsed_seconds":time.monotonic()-started, "smoke":args.smoke}
    (output / "process-results.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    if (render / "report.json").exists():
        report = json.loads((render / "report.json").read_text(encoding="utf-8"))
        (render / "capture-index.json").write_text(json.dumps({"views":report.get("captures", []), "failures":report.get("failures", [])}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result), flush=True)
    return 0 if code == 0 and not failure and not diagnostics and result["memory_pass"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
