<#
.SYNOPSIS
    Installs pptx2pdf - PPTX/PDF converter using LibreOffice
#>

$InstallDir = "$env:USERPROFILE\.local\bin"
$ScriptName = "pptx2pdf.py"
$ScriptBat = "pptx2pdf.cmd"
$ScriptSource = Join-Path $PSScriptRoot $ScriptName

Write-Host "============================================"
Write-Host "  pptx2pdf - Cross-Platform PPTX/PDF Converter"
Write-Host "============================================"
Write-Host ""

$LO = Get-Command "soffice.exe" -ErrorAction SilentlyContinue
if (-not $LO) {
    $LOPaths = @(
        "C:\Program Files\LibreOffice\program\soffice.exe",
        "C:\Program Files (x86)\LibreOffice\program\soffice.exe"
    )
    foreach ($p in $LOPaths) {
        if (Test-Path $p) { $LO = $p; break }
    }
}
if (-not $LO) {
    Write-Host "[1/5] LibreOffice not found. Downloading installer..."
    Start-Process "https://www.libreoffice.org/download/download/"
    Write-Host "  -> Please download and install LibreOffice, then press Enter..."
    Read-Host
}
Write-Host "[1/5] LibreOffice: OK"

Write-Host "[2/5] Checking poppler (pdftoppm for --faithful)..."
try {
    $null = Get-Command "pdftoppm.exe" -ErrorAction Stop
    Write-Host "  -> found"
} catch {
    Write-Host "  -> not found. Install from https://github.com/oschwartz10612/poppler-windows/releases"
    Write-Host "  -> (optional — only needed for --faithful mode)"
}

Write-Host "[3/5] Installing pptx2pdf..."
if (-not (Test-Path $ScriptSource)) {
    Write-Host "Error: $ScriptName not found in current folder."
    exit 1
}
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item $ScriptSource "$InstallDir\$ScriptName" -Force
@"
@echo off
python3 "%USERPROFILE%\.local\bin\pptx2pdf.py" %*
"@ | Out-File -FilePath "$InstallDir\$ScriptBat" -Encoding ASCII -Force

Write-Host "[4/5] Installing Python dependencies..."
try {
    $pip = Get-Command "pip3" -ErrorAction Stop
    & $pip install --user python-pptx img2pdf 2>&1 | Out-Null
    Write-Host "  -> python-pptx, img2pdf installed"
} catch {
    Write-Host "  -> pip3 not found. Install Python 3 from https://python.org"
    Write-Host "  -> then run: pip3 install --user python-pptx img2pdf"
}

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "[5/5] Adding to PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    Write-Host "  -> Added to user PATH. Restart your terminal or log off/on."
} else {
    Write-Host "[5/5] Already in PATH"
}

Write-Host ""
Write-Host "============================================"
Write-Host "  Installation complete!"
Write-Host ""
Write-Host "  Usage:  pptx2pdf arquivo.pptx"
Write-Host "          pptx2pdf --fresh arquivo.pptx"
Write-Host "          pptx2pdf --faithful arquivo.pptx"
Write-Host "          pptx2pdf --help"
Write-Host ""
Write-Host "  Docs:  type $PSScriptRoot\HOWTO.md"
Write-Host "============================================"
