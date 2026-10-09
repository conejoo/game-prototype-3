#Requires -Version 7.0
## Read rendered 960x640 HUD only. No process memory, input or game authority.
function Get-FishingHudPixels([Drawing.Bitmap]$Bitmap, $Template) {
    if ($Bitmap.Width -ne 960 -or $Bitmap.Height -ne 640) { throw 'Fishing pixel driver requires inspected 960x640 client' }
    if ($Template.schema -ne 1 -or $Template.rows.Count -ne 23 -or @($Template.rows | Where-Object {$_ -notmatch '^[01]{200}$'}).Count) { throw 'Invalid BITE pixel template' }
    $bounds=[Drawing.Rectangle]::new(550,480,200,23)
    $locked=$Bitmap.LockBits($bounds,[Drawing.Imaging.ImageLockMode]::ReadOnly,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        if ($locked.Stride -lt 800) {throw 'Invalid screenshot stride'}
        $bytes=[byte[]]::new($locked.Stride*23)
        [Runtime.InteropServices.Marshal]::Copy($locked.Scan0,$bytes,0,$bytes.Length)
    } finally {$Bitmap.UnlockBits($locked)}
    $different=0; $positive=0; $positiveMatched=0
    for ($row=0; $row -lt 23; $row++) {
        for ($column=0; $column -lt 200; $column++) {
            $offset=$row*$locked.Stride+$column*4
            $white=$bytes[$offset] -ge 180 -and $bytes[$offset+1] -ge 180 -and $bytes[$offset+2] -ge 180
            $expected=$Template.rows[$row][$column] -eq '1'
            if ($white -ne $expected) {$different++}
            if ($expected) {$positive++; if ($white) {$positiveMatched++}}
        }
    }
    $bite=$different/4600.0 -lt .035 -and $positive -gt 250 -and $positiveMatched/[double]$positive -gt .94
    $zones=0; $marker=@()
    for ($x=550; $x -lt 922; $x++) {
        $color=$Bitmap.GetPixel($x,452)
        if ($color.R -ge 245 -and $color.G -ge 245 -and $color.B -ge 245) {$marker+=($x-550)}
        foreach ($rgb in @(@(183,71,72),@(181,145,69),@(57,134,108))) {
            if ([math]::Abs($color.R-$rgb[0]) -le 4 -and [math]::Abs($color.G-$rgb[1]) -le 4 -and [math]::Abs($color.B-$rgb[2]) -le 4) {$zones++; break}
        }
    }
    $fight=$zones -ge 350 -and $marker.Count -ge 3 -and $marker.Count -le 5
    $tension=if ($fight) {($marker | Measure-Object -Average).Average/372.0} else {$null}
    return @{bite=$bite;fight=$fight;tension=$tension;bite_difference=$different/4600.0;marker_pixels=$marker.Count;zone_pixels=$zones}
}
