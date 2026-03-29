$ErrorActionPreference = "Stop"

# Paths
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = "$ProjectDir\backend"
$FrontendDir = "$ProjectDir\frontend\public"

# Backend install
Write-Host "`n[Backend] Installing dependencies..."
Push-Location $BackendDir
npm install
Write-Host "[Backend] Starting server..."
Start-Process powershell -ArgumentList "cd '$BackendDir'; npm start" -WindowStyle Hidden
Pop-Location

# Frontend install
Write-Host "`n[Frontend] Installing dependencies..."
Push-Location $FrontendDir
npm install
Write-Host "[Frontend] Starting local preview..."
Start-Process powershell -ArgumentList "cd '$FrontendDir'; npm start" -WindowStyle Hidden
Pop-Location

Start-Sleep -Seconds 2
Start-Process "http://localhost:5001"
Write-Host "`n[Done] Frontend opened in browser. Backend running on http://localhost:5000"
