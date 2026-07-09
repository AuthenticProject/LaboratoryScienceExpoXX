$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "Listening on http://localhost:8000/ ..."
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $path = $request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        
        $escapedPath = $path.Substring(1)
        $decodedPath = [uri]::UnescapeDataString($escapedPath)
        if (-not $decodedPath) { $decodedPath = "index.html" }
        $localPath = Join-Path "d:\00. Me\Code Project\LSE XX" $decodedPath
        
        if (Test-Path $localPath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($localPath)
            
            if ($localPath.EndsWith(".html")) { $response.ContentType = "text/html" }
            elseif ($localPath.EndsWith(".png")) { $response.ContentType = "image/png" }
            elseif ($localPath.EndsWith(".jpg") -or $localPath.EndsWith(".jpeg")) { $response.ContentType = "image/jpeg" }
            elseif ($localPath.EndsWith(".js")) { $response.ContentType = "application/javascript" }
            elseif ($localPath.EndsWith(".css")) { $response.ContentType = "text/css" }
            
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $buf = [System.Text.Encoding]::UTF8.GetBytes("Not Found: $localPath")
            $response.OutputStream.Write($buf, 0, $buf.Length)
        }
        $response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
}
