# Minimal static file server for local testing (no node/python required).
# Service workers refuse to register on file:// origins, so use this to test
# installability, the manifest, and offline behavior before deploying.
param([int]$Port = 8080)

$root = Split-Path -Parent $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Output "Serving $root at http://localhost:$Port/  (Ctrl+C to stop)"

$mime = @{
    ".html" = "text/html; charset=utf-8"; ".css" = "text/css"; ".js" = "application/javascript"
    ".json" = "application/json"; ".png" = "image/png"; ".woff2" = "font/woff2"; ".ico" = "image/x-icon"
}

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        try {
            $path = $ctx.Request.Url.LocalPath
            if ($path -eq "/") { $path = "/index.html" }
            $file = Join-Path $root ($path.TrimStart("/") -replace "/", [IO.Path]::DirectorySeparatorChar)

            if (Test-Path $file -PathType Leaf) {
                $ext = [IO.Path]::GetExtension($file)
                $ctx.Response.ContentType = $mime[$ext]
                if (-not $ctx.Response.ContentType) { $ctx.Response.ContentType = "application/octet-stream" }
                $bytes = [IO.File]::ReadAllBytes($file)
                $ctx.Response.ContentLength64 = $bytes.Length
                if ($ctx.Request.HttpMethod -ne "HEAD") {
                    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
                }
            } else {
                $ctx.Response.StatusCode = 404
            }
        } catch {
            try { $ctx.Response.StatusCode = 500 } catch {}
        } finally {
            $ctx.Response.OutputStream.Close()
        }
    }
} finally {
    $listener.Stop()
}
