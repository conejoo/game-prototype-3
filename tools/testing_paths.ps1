# Pure project path guards; no process, input, or filesystem mutations.
function Resolve-ProjectChildPath {
    param([Parameter(Mandatory)][string]$ProjectRoot, [Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$RelativeRoot)
    $project = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd([char[]]'\/')
    $allowed = [IO.Path]::GetFullPath((Join-Path $project $RelativeRoot)).TrimEnd([char[]]'\/')
    $absolute = [IO.Path]::GetFullPath($Path, $project).TrimEnd([char[]]'\/')
    if (-not $allowed.StartsWith($project + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
        -not $absolute.StartsWith($allowed + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path must be a child of $RelativeRoot."
    }
    # A lexical child through an existing junction/symlink is not a safe child.
    $ancestor = $absolute
    while ($ancestor.Length -gt $project.Length) {
        if (Test-Path -LiteralPath $ancestor) {
            $item = Get-Item -LiteralPath $ancestor -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse point in output path: $ancestor" }
        }
        $ancestor = Split-Path $ancestor -Parent
    }
    return $absolute
}
function Resolve-NativeEvidenceDirectory {
    param([Parameter(Mandatory)][string]$ProjectRoot, [Parameter(Mandatory)][string]$OutputDirectory)
    $absolute = Resolve-ProjectChildPath $ProjectRoot $OutputDirectory 'docs/evidence'
    $relative = [IO.Path]::GetRelativePath((Join-Path $ProjectRoot 'docs/evidence'), $absolute).Replace('\','/')
    if ($relative -notmatch '^(P014|W00[1-9]|W010|F00[1-9]|F010|N018|G009|FS008|R016)/[^/]+(?:/.*)?$') {
        throw 'Native output must be a run subdirectory of docs/evidence/P014, W001-W010, F001-F010, N018, G009, FS008 or R016.'
    }
    return $absolute
}
function Resolve-NativeStandaloneDirectory {
    param([Parameter(Mandatory)][string]$ProjectRoot, [Parameter(Mandatory)][string]$Directory,
          [Parameter(Mandatory)][string]$EvidenceDirectory)
    $evidence = Resolve-NativeEvidenceDirectory $ProjectRoot $EvidenceDirectory
    $standalone = [IO.Path]::GetFullPath($Directory).TrimEnd([char[]]'\/')
    $temporary = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd([char[]]'\/')
    $relative = [IO.Path]::GetRelativePath($temporary, $standalone)
    if ($relative -notmatch '^ReturningFair-(N018|G009|FS008|R016)-[A-Za-z0-9_-]{1,64}$' -or
        -not $standalone.StartsWith($temporary + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Standalone input requires an owned N018/G009/FS008/R016 directory directly below TEMP.'
    }
    $task = $Matches[1]
    $evidenceRelative = [IO.Path]::GetRelativePath((Join-Path $ProjectRoot 'docs/evidence'),$evidence).Replace('\','/')
    if (-not $evidenceRelative.StartsWith($task + '/', [StringComparison]::Ordinal)) { throw 'Standalone task and evidence differ.' }
    $ancestor = $standalone
    while ($ancestor.Length -gt 0) {
        if ((Test-Path -LiteralPath $ancestor) -and ((Get-Item -LiteralPath $ancestor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw 'Reparse point in standalone path.'
        }
        $parent = Split-Path $ancestor -Parent
        if ($parent -eq $ancestor) { break }
        $ancestor = $parent
    }
    foreach ($leaf in @('ReturningFair.exe','ReturningFair.pck','override.cfg')) {
        $copy = Join-Path $standalone $leaf
        $canonical = Join-Path $ProjectRoot ('builds/windows/' + $leaf)
        if (-not (Test-Path -LiteralPath $copy -PathType Leaf) -or
            ((Get-Item -LiteralPath $copy -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            ((Get-Item -LiteralPath $canonical -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            (Get-FileHash -LiteralPath $copy -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $canonical -Algorithm SHA256).Hash) {
            throw 'Standalone copy differs from this project release package.'
        }
    }
    return $standalone
}
function Assert-NewEvidenceCaptures {
    param([Parameter(Mandatory)][string]$Directory, [AllowEmptyCollection()][string[]]$Labels)
    if (@($Labels | ForEach-Object { $_.ToUpperInvariant() } | Select-Object -Unique).Count -ne $Labels.Count) { throw 'Duplicate capture labels.' }
    foreach ($label in $Labels) {
        if ($label -notmatch '^[A-Za-z0-9_-]{1,64}$') { throw 'Invalid capture label.' }
        if (Test-Path -LiteralPath (Join-Path $Directory ($label + '.png'))) { throw "Capture would overwrite evidence: $label" }
    }
}
