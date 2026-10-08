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
. (Join-Path $PSScriptRoot 'native_input_commands.ps1')
. (Join-Path $PSScriptRoot 'testing_paths.ps1')
$outputPath = Resolve-NativeEvidenceDirectory $projectRoot $OutputDirectory
$request = Get-Content -LiteralPath $CommandFile -Raw | ConvertFrom-Json
$requestedMs = Assert-NativeInputRequest $request
$steps = $request.steps
Assert-NewEvidenceCaptures $outputPath @($steps | Where-Object op -eq 'capture' | ForEach-Object label)
$expectedExecutable = [IO.Path]::GetFullPath((Join-Path $projectRoot 'builds/windows/ReturningFair.exe'))
$target = Get-Process -Id $TargetProcessId
if ($target.Path -ne $expectedExecutable) { throw 'Target is not this project release executable.' }
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
    public static void ValidatePoint(int x, int y) {
        Guard(); Rect rect; if (!GetClientRect(Window, out rect)) throw new InvalidOperationException("Client rectangle unavailable.");
        if (x < 0 || y < 0 || x >= rect.Right || y >= rect.Bottom) throw new ArgumentOutOfRangeException("Pointer outside client.");
    }
    public static void Pointer(int x, int y) {
        ValidatePoint(x, y);
        var point = new Point { X=x, Y=y };
        if (!ClientToScreen(Window, ref point)) throw new InvalidOperationException("Client position unavailable.");
        if (!SetCursorPos(point.X, point.Y)) throw new InvalidOperationException("Pointer failed.");
    }
    public static void Mouse(bool up) {
        if (!up) { Guard(); if ((GetAsyncKeyState(0x01) & 0x8000) != 0) throw new InvalidOperationException("Left mouse button already held."); }
        var input = new Input { Type=0 }; input.Value.Mouse = new MouseData { Flags=up ? 4u : 2u }; Send(input);
    }
}
'@
}
Add-Type -AssemblyName System.Drawing
$requestId = [Guid]::NewGuid().ToString('N')
$timer = [Diagnostics.Stopwatch]::StartNew()
$result = $null
try {
    [ReturningFairNative]::Attach($TargetProcessId)
    $result = Invoke-NativeInputSteps $steps {
        param($operation, $arguments)
        switch ($operation) {
            'Guard' { [ReturningFairNative]::Guard() }
            'ValidatePoint' { [ReturningFairNative]::ValidatePoint($arguments[0], $arguments[1]) }
            'Key' { [ReturningFairNative]::Key($arguments[0], $arguments[1]) }
            'Mouse' { [ReturningFairNative]::Mouse($arguments[0]) }
            'Wait' { [ReturningFairNative]::Wait($arguments[0]) }
            'WaitForQuit' { Start-Sleep -Milliseconds $arguments[0] }
            'Pointer' { [ReturningFairNative]::Pointer($arguments[0], $arguments[1]) }
            'Capture' {
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
                    $capturePath = Join-Path $outputPath ($arguments[0] + '.png')
                    $captureStream = [IO.File]::Open($capturePath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
                    try { $bitmap.Save($captureStream, [Drawing.Imaging.ImageFormat]::Png) }
                    finally { $captureStream.Dispose() }
                } finally { $graphics.Dispose(); $bitmap.Dispose() }
            }
            default { throw "Unsupported native dispatch: $operation" }
        }
    }
} catch {
    $result = @{ ok=$false; error=$_.Exception.Message; failed_step=$null; steps=@(); cleanup_errors=@(); unreleased_keys=@(); mouse_unreleased=$false; requested_duration_ms=$requestedMs }
}
finally {
    $result.id = $requestId
    $result.schema_version = 2
    $result.target_pid = $TargetProcessId
    $result.executable = $expectedExecutable
    $result.elapsed_ms = $timer.Elapsed.TotalMilliseconds
    $reportStream = [IO.File]::Open((Join-Path $outputPath ($requestId + '.json')), [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    $reportWriter = [IO.StreamWriter]::new($reportStream, [Text.UTF8Encoding]::new($false))
    try { $reportWriter.Write(($result | ConvertTo-Json -Depth 12)) }
    finally { $reportWriter.Dispose() }
    $result | ConvertTo-Json -Depth 12
}
if (-not $result.ok) { exit 1 }
