# Install-Run.ps1
$ProjectDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1️⃣ Create folders
$folders = @(
    "$ProjectDir\backend\uploads",
    "$ProjectDir\frontend\public"
)

foreach ($f in $folders) {
    if (-Not (Test-Path $f)) {
        New-Item -ItemType Directory -Path $f | Out-Null
        Write-Host "[Info] Created folder: $f"
    }
}

# 2️⃣ Write clean package.json
$pkgJson = @"
{
  "name": "chatgpt-file-uploader-backend",
  "version": "1.0.0",
  "description": "Backend for file uploader project",
  "type": "module",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "multer": "^1.4.5"
  },
  "engines": {
    "node": "20.x"
  },
  "keywords": [
    "file",
    "uploader",
    "backend",
    "express",
    "multer"
  ],
  "author": "1wb1965197116-jpg",
  "license": "MIT"
}
"@

$pkgPath = "$ProjectDir\backend\package.json"
$pkgJson | Set-Content -Path $pkgPath -Encoding UTF8
Write-Host "[Info] package.json written to backend folder."

# 3️⃣ Install dependencies
Push-Location "$ProjectDir\backend"
Write-Host "[Info] Installing backend dependencies..."
npm install
Pop-Location

# 4️⃣ Start backend server
Write-Host "[Info] Starting backend server..."
Start-Process powershell -ArgumentList "cd `"$ProjectDir\backend`"; npm start" -WindowStyle Normal

# 5️⃣ Open frontend preview
$indexPath = "$ProjectDir\frontend\public\index.html"
if (Test-Path $indexPath) {
    Write-Host "[Info] Opening frontend preview..."
    Start-Process "$indexPath"
} else {
    Write-Host "[Warning] index.html not found in frontend/public."
}

Write-Host "[Done] Local preview ready!"
