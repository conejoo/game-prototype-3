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
    if ($relative -notmatch '^(P014|W00[1-9]|W010|F00[1-9]|F010|N018)/[^/]+(?:/.*)?$') {
        throw 'Native output must be a run subdirectory of docs/evidence/P014, W001-W010, F001-F010 or N018.'
    }
    return $absolute
}
function Assert-NewEvidenceCaptures {
    param([Parameter(Mandatory)][string]$Directory, [AllowEmptyCollection()][string[]]$Labels)
    if (@($Labels | ForEach-Object { $_.ToUpperInvariant() } | Select-Object -Unique).Count -ne $Labels.Count) { throw 'Duplicate capture labels.' }
    foreach ($label in $Labels) {
        if ($label -notmatch '^[A-Za-z0-9_-]{1,64}$') { throw 'Invalid capture label.' }
        if (Test-Path -LiteralPath (Join-Path $Directory ($label + '.png'))) { throw "Capture would overwrite evidence: $label" }
    }
}
