$ErrorActionPreference = "Stop"

# --------------------------
# Paths
# --------------------------
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = "$ProjectDir\backend"
$FrontendDir = "$ProjectDir\frontend\public"
$UploadsDir = "$BackendDir\uploads"
$DepsDir = "$BackendDir\dependencies"
$ModulesDir = "$BackendDir\modules"
$PluginsDir = "$BackendDir\plugins"
$ScriptsDir = "$BackendDir\scripts"

# --------------------------
# Folder Setup
# --------------------------
$folders = @($UploadsDir, $DepsDir, $ModulesDir, $PluginsDir, $ScriptsDir)
foreach ($f in $folders) {
    if (-not (Test-Path $f)) {
        Write-Host "[Setup] Creating folder: $f"
        New-Item -ItemType Directory -Path $f
    }
}

# --------------------------
# package.json Setup
# --------------------------
$PkgPath = "$BackendDir\package.json"
if (-not (Test-Path $PkgPath)) {
    Write-Host "[Setup] Creating clean package.json..."
    $pkg = @{
        name = "backend"
        version = "1.0.0"
        description = "Backend for ChatGPT File Uploader"
        main = "server.js"
        scripts = @{
            start = "node server.js"
        }
        dependencies = @{}
        engines = @{
            node = "20.x"
        }
    }
    $pkg | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $PkgPath
}

# --------------------------
# Backend install & start
# --------------------------
Write-Host "`n[Backend] Installing dependencies..."
Push-Location $BackendDir
npm install
Write-Host "[Backend] Starting server..."
Start-Process powershell -ArgumentList "cd '$BackendDir'; npm start" -WindowStyle Hidden
Pop-Location

# --------------------------
# Frontend setup & start
# --------------------------
Write-Host "`n[Frontend] Installing dependencies..."
Push-Location $FrontendDir
if (-not (Test-Path "$FrontendDir\package.json")) {
    Write-Host "[Frontend] Creating minimal package.json..."
    $fPkg = @{
        name = "frontend"
        version = "1.0.0"
        description = "Frontend for ChatGPT File Uploader"
        scripts = @{
            start = "serve -l 5001"
        }
        dependencies = @{
            serve = "latest"
        }
    }
    $fPkg | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 "$FrontendDir\package.json"
}
npm install
Write-Host "[Frontend] Starting local preview..."
Start-Process powershell -ArgumentList "cd '$FrontendDir'; npm start" -WindowStyle Hidden
Pop-Location

# --------------------------
# Open frontend in browser
# --------------------------
Start-Sleep -Seconds 2
Start-Process "http://localhost:5001"
Write-Host "`n[Done] Frontend opened in browser. Backend running on http://localhost:5000"
