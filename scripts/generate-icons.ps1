# Generates the app icons for the PWA manifest using GDI+ (no external tools needed).
# Draws a simplified version of the app's own "blooming tree" glyph on the accent
# background, matching Daimoku Practice Tracker.dc.html's treeTier() top tier.
Add-Type -AssemblyName System.Drawing

function New-AppIcon {
    param(
        [int]$Size,
        [string]$OutPath,
        [bool]$RoundedCorners = $false
    )

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    $bg = [System.Drawing.Color]::FromArgb(255, 0xC6, 0x71, 0x39)   # --color-accent
    $bgBrush = New-Object System.Drawing.SolidBrush($bg)

    if ($RoundedCorners) {
        $radius = [int]($Size * 0.22)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $radius * 2
        $path.AddArc(0, 0, $d, $d, 180, 90)
        $path.AddArc($Size - $d, 0, $d, $d, 270, 90)
        $path.AddArc($Size - $d, $Size - $d, $d, $d, 0, 90)
        $path.AddArc(0, $Size - $d, $d, $d, 90, 90)
        $path.CloseFigure()
        $g.FillPath($bgBrush, $path)
    } else {
        $g.FillRectangle($bgBrush, 0, 0, $Size, $Size)
    }

    # Trunk
    $trunkColor = [System.Drawing.Color]::FromArgb(255, 0x64, 0x5C, 0x50)  # --color-neutral-700
    $trunkBrush = New-Object System.Drawing.SolidBrush($trunkColor)
    $trunkW = $Size * 0.075
    $trunkH = $Size * 0.30
    $trunkX = ($Size - $trunkW) / 2
    $trunkY = $Size * 0.66
    $trunkRect = New-Object System.Drawing.RectangleF($trunkX, $trunkY, $trunkW, $trunkH)
    $trunkPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $tr = $trunkW * 0.35
    $trunkPath.AddArc($trunkX, $trunkY, $tr, $tr, 180, 90)
    $trunkPath.AddArc($trunkX + $trunkW - $tr, $trunkY, $tr, $tr, 270, 90)
    $trunkPath.AddLine(($trunkX + $trunkW), ($trunkY + $trunkH), $trunkX, ($trunkY + $trunkH))
    $trunkPath.CloseFigure()
    $g.FillPath($trunkBrush, $trunkPath)

    # Canopy — five leaves, cream against the orange background (matches the
    # in-app "Florescendo" tree tier: leafCount 5)
    $leafColor = [System.Drawing.Color]::FromArgb(255, 0xF5, 0xEA, 0xD8)  # --color-bg (cream)
    $leafBrush = New-Object System.Drawing.SolidBrush($leafColor)
    $cx = $Size / 2.0
    $cy = $Size * 0.44
    $leaves = @(
        @{ dx = 0.0;    dy = -0.14; r = 0.20 },
        @{ dx = -0.185; dy = 0.02;  r = 0.15 },
        @{ dx = 0.185;  dy = 0.02;  r = 0.15 },
        @{ dx = -0.11;  dy = 0.15;  r = 0.125 },
        @{ dx = 0.11;   dy = 0.15;  r = 0.125 }
    )
    foreach ($leaf in $leaves) {
        $r = $Size * $leaf.r
        $lx = $cx + ($Size * $leaf.dx) - $r
        $ly = $cy + ($Size * $leaf.dy) - $r
        $g.FillEllipse($leafBrush, $lx, $ly, $r * 2, $r * 2)
    }

    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$root = "C:\Users\dtsuj\Claude Projects\Daimoku Practice Tracker\icons"
New-AppIcon -Size 512 -OutPath "$root\icon-512.png" -RoundedCorners $false
New-AppIcon -Size 192 -OutPath "$root\icon-192.png" -RoundedCorners $false
New-AppIcon -Size 180 -OutPath "$root\apple-touch-icon.png" -RoundedCorners $true
Write-Output "done"
