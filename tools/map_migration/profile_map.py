"""M018 rendered development-machine profiler. No dependencies or normal saves."""
import argparse, ctypes, json, os, subprocess, time
from ctypes import wintypes
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GODOT = Path('D:/development/Godot_v4.7.2-stable_mono_win64/Godot_v4.7.2-stable_mono_win64_console.exe')
class MemoryCounters(ctypes.Structure):
    _fields_ = [('cb', wintypes.DWORD), ('PageFaultCount', wintypes.DWORD)] + [(name, ctypes.c_size_t) for name in ('PeakWorkingSetSize','WorkingSetSize','QuotaPeakPagedPoolUsage','QuotaPagedPoolUsage','QuotaPeakNonPagedPoolUsage','QuotaNonPagedPoolUsage','PagefileUsage','PeakPagefileUsage')]
kernel = ctypes.WinDLL('kernel32', use_last_error=True)
psapi = ctypes.WinDLL('psapi', use_last_error=True)
kernel.OpenProcess.argtypes = [wintypes.DWORD, wintypes.BOOL, wintypes.DWORD]
kernel.OpenProcess.restype = wintypes.HANDLE
kernel.CloseHandle.argtypes = [wintypes.HANDLE]
psapi.GetProcessMemoryInfo.argtypes = [wintypes.HANDLE, ctypes.POINTER(MemoryCounters), wintypes.DWORD]
psapi.GetProcessMemoryInfo.restype = wintypes.BOOL

def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('--label', required=True)
    parser.add_argument('--smoke', action='store_true')
    args = parser.parse_args()
    if not args.label.replace('-', '').isalnum(): parser.error('label must be alphanumeric/hyphen')
    output = ROOT / 'docs/evidence/M018' / args.label
    output.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    env['APPDATA'] = str(ROOT / 'builds/m018-profile-data' / args.label)
    env['LOCALAPPDATA'] = str(ROOT / 'builds/m018-profile-local-data' / args.label)
    command = [str(GODOT), '--path', str(ROOT / 'game'), '--disable-vsync', '--max-fps', '0', '--script', 'res://tests/map_performance_profile.gd', '--', '--save-slot=m018-profile', '--profile-output=' + str(output)]
    if args.smoke: command += ['--profile-warmup=1', '--profile-duration=2', '--profile-runs=1']
    (output / 'launch.json').write_text(json.dumps({'argv':command, 'cwd':str(ROOT), 'APPDATA':env['APPDATA'], 'LOCALAPPDATA':env['LOCALAPPDATA'], 'smoke':args.smoke}, indent=2) + '\n', encoding='utf-8')
    with (output / 'runtime.log').open('w', encoding='utf-8') as log, (output / 'working-set.csv').open('w', encoding='utf-8') as csv:
        process = subprocess.Popen(command, cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT, creationflags=subprocess.CREATE_NO_WINDOW)
        handle = None; engine_pid = None

        csv.write('elapsed_seconds,stage,working_set_bytes,peak_working_set_bytes,pagefile_bytes\n')
        samples = []; started = time.monotonic(); stage = 'startup'; last_stage = ''
        try:
            while process.poll() is None:
                try:
                    stage_record = json.loads((output / 'stage.json').read_text(encoding='utf-8'))
                    stage = stage_record['stage']
                    if engine_pid is None:
                        engine_pid = stage_record['pid']
                        handle = kernel.OpenProcess(0x0400 | 0x0010, False, engine_pid)
                        if not handle: raise ctypes.WinError(ctypes.get_last_error())
                except (FileNotFoundError, json.JSONDecodeError): pass
                counters = MemoryCounters(); counters.cb = ctypes.sizeof(counters)
                if handle and psapi.GetProcessMemoryInfo(handle, ctypes.byref(counters), counters.cb):
                    row = {'seconds':time.monotonic()-started, 'stage':stage, 'working_set_bytes':counters.WorkingSetSize, 'peak_working_set_bytes':counters.PeakWorkingSetSize, 'pagefile_bytes':counters.PagefileUsage}
                    samples.append(row)
                    csv.write(f"{row['seconds']:.6f},{stage},{counters.WorkingSetSize},{counters.PeakWorkingSetSize},{counters.PagefileUsage}\n"); csv.flush()
                if stage != last_stage: print(f'{args.label}: {stage}', flush=True); last_stage = stage
                if time.monotonic() - started > (240 if args.smoke else 1500):
                    process.terminate(); raise TimeoutError('Profiler exceeded bounded deadline')
                time.sleep(0.25)
        finally:
            if handle: kernel.CloseHandle(handle)
    code = process.wait()
    runtime_errors = [line for line in (output / 'runtime.log').read_text(encoding='utf-8').splitlines() if 'SCRIPT ERROR:' in line or line.startswith('ERROR:')]
    baseline = [x['working_set_bytes'] for x in samples if x['stage'] == 'checkpoint-baseline']
    final = [x['working_set_bytes'] for x in samples if x['stage'] == 'checkpoint-final']
    peak = max((x['peak_working_set_bytes'] for x in samples), default=0)
    growth = max(final) - max(baseline) if baseline and final else None
    result = {'launcher_pid':process.pid, 'engine_pid':engine_pid, 'engine_exit':code, 'runtime_errors':runtime_errors, 'peak_working_set_bytes':peak, 'baseline_working_set_bytes':baseline, 'final_working_set_bytes':final, 'growth_bytes':growth, 'memory_pass':peak <= 2*1024**3 and growth is not None and growth <= 64*1024**2, 'sample_period_seconds':0.25, 'elapsed_seconds':time.monotonic()-started}
    (output / 'process-results.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result), flush=True)
    return code if code else (0 if result['memory_pass'] and not runtime_errors else 1)

if __name__ == '__main__': raise SystemExit(main())
