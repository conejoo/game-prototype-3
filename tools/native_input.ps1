#Requires -Version 7.0
param(
    [Parameter(Mandatory)][int]$TargetProcessId,
    [Parameter(Mandatory)][string]$CommandFile,
    [Parameter(Mandatory)][string]$OutputDirectory
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# Native input only. No Godot bridge, game-state commands or UI Automation.
$projectRoot = Split-Path $PSScriptRoot -Parent
$expectedExecutable = [IO.Path]::GetFullPath((Join-Path $projectRoot 'builds/windows/ReturningFair.exe'))
$target = Get-Process -Id $TargetProcessId
if ($target.Path -ne $expectedExecutable) { throw 'Target is not this project release executable.' }
. (Join-Path $PSScriptRoot 'testing_paths.ps1')
$outputPath = Resolve-NativeEvidenceDirectory $projectRoot $OutputDirectory
$request = Get-Content -LiteralPath $CommandFile -Raw | ConvertFrom-Json
$steps = @($request.steps)
if ($steps.Count -lt 1 -or $steps.Count -gt 32) { throw 'Expected 1-32 steps.' }
$allowedKeys = @{ W=0x57; A=0x41; S=0x53; D=0x44; E=0x45; J=0x4A; SPACE=0x20; ESC=0x1B; R=0x52; F10=0x79; TAB=0x09; ENTER=0x0D }
$totalMs = 0
foreach ($step in $steps) {
    if ($step.op -notin @('hold','wait','pointer','click','capture','quit')) { throw "Unknown operation: $($step.op)" }
    if ($step.op -in @('hold','wait')) {
        if ($step.duration_ms -lt 16 -or $step.duration_ms -gt 5000) { throw 'Duration must be 16-5000ms.' }
        $totalMs += $step.duration_ms
    }
    if ($step.op -eq 'hold') {
        if (@($step.keys).Count -lt 1 -or @($step.keys).Count -gt 4) { throw 'Hold requires 1-4 keys.' }
        foreach ($key in $step.keys) { if (-not $allowedKeys.ContainsKey($key)) { throw "Key not allowed: $key" } }
        if (@($step.keys | Select-Object -Unique).Count -ne @($step.keys).Count) { throw 'Duplicate key.' }
    }
    if ($step.op -eq 'capture' -and $step.label -notmatch '^[A-Za-z0-9_-]{1,64}$') { throw 'Invalid capture label.' }
    if ($step.op -eq 'quit' -and $step -ne $steps[-1]) { throw 'Quit must be final step.' }
}
if ($totalMs -gt 30000) { throw 'Request exceeds 30 seconds.' }
Assert-NewEvidenceCaptures $outputPath @($steps | Where-Object op -eq 'capture' | ForEach-Object label)
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null

if (-not ('ReturningFairNative' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
public static class ReturningFairNative {
    [StructLayout(LayoutKind.Sequential)] public struct Point { public int X, Y; }
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] struct Keyboard { public ushort Vk, Scan; public uint Flags, Time; public UIntPtr Extra; }
    [StructLayout(LayoutKind.Sequential)] struct MouseData { public int X, Y; public uint Data, Flags, Time; public UIntPtr Extra; }
    [StructLayout(LayoutKind.Explicit)] struct Payload { [FieldOffset(0)] public Keyboard Key; [FieldOffset(0)] public MouseData Mouse; }
    [StructLayout(LayoutKind.Sequential)] struct Input { public uint Type; public Payload Value; }
    [DllImport("user32.dll", SetLastError=true)] static extern uint SendInput(uint count, Input[] inputs, int size);
    [DllImport("user32.dll")] static extern uint MapVirtualKey(uint code, uint type);
    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr window, out uint pid);
    delegate bool WindowCallback(IntPtr window, IntPtr parameter);
    [DllImport("user32.dll")] static extern bool EnumWindows(WindowCallback callback, IntPtr parameter);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern int GetWindowText(IntPtr window, System.Text.StringBuilder title, int length);
    [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr window);
    [DllImport("user32.dll")] static extern bool BringWindowToTop(IntPtr window);
    [DllImport("kernel32.dll")] static extern uint GetCurrentThreadId();
    [DllImport("user32.dll")] static extern bool AttachThreadInput(uint first, uint second, bool attach);
    [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr window, int command);
    [DllImport("user32.dll")] static extern short GetAsyncKeyState(int key);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr window, out Rect rect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr window, ref Point point);
    [DllImport("user32.dll")] static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    [DllImport("user32.dll", SetLastError=true)] static extern IntPtr OpenInputDesktop(uint flags, bool inherit, uint access);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern bool GetUserObjectInformation(IntPtr obj, int index, System.Text.StringBuilder value, uint length, out uint needed);
    [DllImport("user32.dll")] static extern bool CloseDesktop(IntPtr desktop);
    public static IntPtr Window;
    static uint ProcessId;
    public static void Guard() {
        uint actual; GetWindowThreadProcessId(GetForegroundWindow(), out actual);
        if (actual != ProcessId || GetForegroundWindow() != Window) throw new InvalidOperationException("Release lost foreground focus; stopped.");
    }
    public static void Attach(int pid) {
        if (IntPtr.Size != 8 || Marshal.SizeOf(typeof(Input)) != 40) throw new InvalidOperationException("Requires 64-bit INPUT layout.");
        IntPtr desktop = OpenInputDesktop(0, false, 1);
        if (desktop == IntPtr.Zero) throw new InvalidOperationException("Input desktop unavailable; unlock desktop.");
        try {
            uint needed; var name = new System.Text.StringBuilder(128);
            if (!GetUserObjectInformation(desktop, 2, name, 256, out needed) || name.ToString() != "Default")
                throw new InvalidOperationException("Desktop locked or not Default; no input sent.");
        } finally { CloseDesktop(desktop); }
        ProcessId = (uint)pid;
        var windows = new System.Collections.Generic.List<IntPtr>();
        EnumWindows((window, parameter) => {
            uint owner; GetWindowThreadProcessId(window, out owner);
            if (owner == ProcessId) {
                var title = new System.Text.StringBuilder(256); GetWindowText(window, title, title.Capacity);
                if (title.ToString().StartsWith("Returning Fair")) windows.Add(window);
            }
            return true;
        }, IntPtr.Zero);
        if (windows.Count != 1) throw new InvalidOperationException("Expected exactly one release game window; found " + windows.Count);
        Window = windows[0];
        SetThreadDpiAwarenessContext(new IntPtr(-4));
        ShowWindow(Window, 9); SetForegroundWindow(Window);
        uint foregroundOwner;
        uint foregroundThread = GetWindowThreadProcessId(GetForegroundWindow(), out foregroundOwner);
        uint currentThread = GetCurrentThreadId();
        if (foregroundOwner != ProcessId && foregroundThread != currentThread) {
            bool attached = AttachThreadInput(currentThread, foregroundThread, true);
            try { if (attached) { BringWindowToTop(Window); SetForegroundWindow(Window); } }
            finally { if (attached) AttachThreadInput(currentThread, foregroundThread, false); }
        }
        Thread.Sleep(150); Guard();
    }
    static void Send(Input input) {
        if (SendInput(1, new Input[]{input}, Marshal.SizeOf(typeof(Input))) != 1)
            throw new InvalidOperationException("SendInput failed, Win32=" + Marshal.GetLastWin32Error());
    }
    public static void Key(int vk, bool up) {
        if (!up) { Guard(); if ((GetAsyncKeyState(vk) & 0x8000) != 0) throw new InvalidOperationException("Requested key already held."); }
        var input = new Input { Type = 1 };
        input.Value.Key = new Keyboard { Scan = (ushort)MapVirtualKey((uint)vk, 0), Flags = 8u | (up ? 2u : 0u) };
        Send(input);
    }
    public static void Wait(int ms) {
        var timer = Stopwatch.StartNew();
        while (timer.ElapsedMilliseconds < ms) { Guard(); Thread.Sleep((int)Math.Max(1, Math.Min(10, ms - timer.ElapsedMilliseconds))); }
        Guard();
    }
    public static void Pointer(int x, int y) {
        Guard(); Rect rect; if (!GetClientRect(Window, out rect)) throw new InvalidOperationException("Client rectangle unavailable.");
        if (x < 0 || y < 0 || x >= rect.Right || y >= rect.Bottom) throw new ArgumentOutOfRangeException("Pointer outside client.");
        var point = new Point { X=x, Y=y }; ClientToScreen(Window, ref point);
        if (!SetCursorPos(point.X, point.Y)) throw new InvalidOperationException("Pointer failed.");
    }
    public static void Mouse(bool up) {
        if (!up) Guard();
        var input = new Input { Type=0 }; input.Value.Mouse = new MouseData { Flags=up ? 4u : 2u }; Send(input);
    }
}
'@
}
Add-Type -AssemblyName System.Drawing
$trace = [Collections.Generic.List[object]]::new()
$held = [Collections.Generic.List[int]]::new()
$mouseHeld = $false
$requestId = [Guid]::NewGuid().ToString('N')
$timer = [Diagnostics.Stopwatch]::StartNew()
$failure = $null
try {
    [ReturningFairNative]::Attach($TargetProcessId)
    foreach ($step in $steps) {
        $started = $timer.Elapsed.TotalMilliseconds
        switch ($step.op) {
            'hold' {
                try {
                    foreach ($key in $step.keys) { $vk = $allowedKeys[$key]; [ReturningFairNative]::Key($vk, $false); $held.Add($vk) }
                    [ReturningFairNative]::Wait($step.duration_ms)
                } finally {
                    foreach ($vk in $held) { [ReturningFairNative]::Key($vk, $true) }
                    $held.Clear()
                }
            }
            'wait' { [ReturningFairNative]::Wait($step.duration_ms) }
            'pointer' { [ReturningFairNative]::Pointer($step.x, $step.y) }
            'click' {
                [ReturningFairNative]::Pointer($step.x, $step.y)
                try { [ReturningFairNative]::Mouse($false); $mouseHeld = $true; [ReturningFairNative]::Wait(50) }
                finally { if ($mouseHeld) { [ReturningFairNative]::Mouse($true); $mouseHeld = $false } }
            }
            'capture' {
                [ReturningFairNative]::Guard()
                $rect = [ReturningFairNative+Rect]::new()
                if (-not [ReturningFairNative]::GetClientRect([ReturningFairNative]::Window, [ref]$rect)) { throw 'Client capture unavailable.' }
                $point = [ReturningFairNative+Point]::new()
                [void][ReturningFairNative]::ClientToScreen([ReturningFairNative]::Window, [ref]$point)
                $bitmap = [Drawing.Bitmap]::new($rect.Right, $rect.Bottom)
                $graphics = [Drawing.Graphics]::FromImage($bitmap)
                try {
                    $graphics.CopyFromScreen($point.X, $point.Y, 0, 0, $bitmap.Size)
                    [ReturningFairNative]::Guard()
                    $capturePath = Join-Path $outputPath ($step.label + '.png')
                    $captureStream = [IO.File]::Open($capturePath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                    try { $bitmap.Save($captureStream, [Drawing.Imaging.ImageFormat]::Png) }
                    finally { $captureStream.Dispose() }
                } finally { $graphics.Dispose(); $bitmap.Dispose() }
            }
            'quit' {
                try { [ReturningFairNative]::Key(0x79, $false); Start-Sleep -Milliseconds 50 }
                finally { [ReturningFairNative]::Key(0x79, $true) }
            }
        }
        $trace.Add(@{ step=$step; elapsed_ms=$timer.Elapsed.TotalMilliseconds-$started; completed_utc=[DateTime]::UtcNow.ToString('o') })
    }
} catch { $failure = $_.Exception.Message }
finally {
    foreach ($vk in $held) { try { [ReturningFairNative]::Key($vk, $true) } catch {} }
    if ($mouseHeld) { try { [ReturningFairNative]::Mouse($true) } catch {} }
    $result = @{ id=$requestId; target_pid=$TargetProcessId; executable=$expectedExecutable; ok=($null -eq $failure); error=$failure; steps=@($trace.ToArray()); elapsed_ms=$timer.Elapsed.TotalMilliseconds }
    $result | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $outputPath ($requestId + '.json')) -Encoding utf8NoBOM
    $result | ConvertTo-Json -Depth 12
}
if ($failure) { exit 1 }
