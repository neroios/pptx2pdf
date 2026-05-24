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

# ---- Install LibreOffice if missing ----
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
    Write-Host "[1/3] LibreOffice not found. Downloading installer..."
    $url = "https://www.libreoffice.org/download/download/"
    Write-Host "  -> Opening download page in browser..."
    Start-Process $url
    Write-Host "  -> Please download and install LibreOffice, then press Enter..."
    Read-Host
}

Write-Host "[1/3] LibreOffice: OK"

# ---- Copy script ----
Write-Host "[2/3] Installing pptx2pdf..."

if (-not (Test-Path $ScriptSource)) {
    Write-Host "Error: $ScriptName not found in current folder."
    exit 1
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
Copy-Item $ScriptSource "$InstallDir\$ScriptName" -Force

# Create .cmd wrapper so it can be run from cmd.exe too
@"
@echo off
python3 "%USERPROFILE%\.local\bin\pptx2pdf.py" %*
"@ | Out-File -FilePath "$InstallDir\$ScriptBat" -Encoding ASCII -Force

# ---- Add to PATH ----
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($UserPath -notlike "*$InstallDir*") {
    Write-Host "[3/3] Adding to PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", "User")
    Write-Host "  -> Added to user PATH. Restart your terminal or log off/on."
} else {
    Write-Host "[3/3] Already in PATH"
}

Write-Host ""
Write-Host "============================================"
Write-Host "  Installation complete!"
Write-Host "  Usage:  pptx2pdf arquivo.pptx"
Write-Host "          pptx2pdf *.pptx ./pdfs --delete"
Write-Host "          pptx2pdf arquivo.pdf"
Write-Host "============================================"
