# =============================================================================
# convert_thermal.ps1
# Converts DJI M3T thermal JPEGs (*_T.JPG) to GeoTIFFs on Windows using Docker.
#
# Usage (in PowerShell):
#   .\convert_thermal.ps1 -ImagesFolder "C:\path\to\your\thermal\images"
#
# Example:
#   .\convert_thermal.ps1 -ImagesFolder "C:\Users\YourName\Desktop\lumley2_images"
#
# Output:
#   A "tiff\" subfolder will be created inside your images folder.
#
# Requirements:
#   - Docker Desktop for Windows must be installed and running
#   - The rjpeg2tiff folder must be in the same directory as this script
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$ImagesFolder
)

# --- Resolve paths -----------------------------------------------------------
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$ToolsDir    = Join-Path $ScriptDir "rjpeg2tiff"
$ImagesDir   = Resolve-Path $ImagesFolder -ErrorAction SilentlyContinue

if (-not $ImagesDir) {
    Write-Host ""
    Write-Host "  ERROR: Images folder not found: $ImagesFolder" -ForegroundColor Red
    Write-Host ""
    exit 1
}
$ImagesDir = $ImagesDir.Path

# --- Sanity checks -----------------------------------------------------------
if (-not (Test-Path $ToolsDir)) {
    Write-Host ""
    Write-Host "  ERROR: rjpeg2tiff folder not found next to this script." -ForegroundColor Red
    Write-Host "         Expected at: $ToolsDir" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Check Docker is available
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host ""
    Write-Host "  ERROR: Docker command not found." -ForegroundColor Red
    Write-Host "         Please install Docker Desktop from https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Check Docker daemon is running
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "  ERROR: Docker is not running." -ForegroundColor Red
    Write-Host "         Please open Docker Desktop and wait for it to start, then try again." -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Count thermal images
$ThermalFiles  = Get-ChildItem -Path $ImagesDir -Filter "*_T.JPG" -File
$ThermalFiles += Get-ChildItem -Path $ImagesDir -Filter "*_T.jpg" -File
$ThermalCount  = $ThermalFiles.Count

if ($ThermalCount -eq 0) {
    Write-Host ""
    Write-Host "  WARNING: No thermal images (*_T.JPG) found in: $ImagesDir" -ForegroundColor Yellow
    Write-Host "           Make sure your images end in _T.JPG" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# --- Convert paths for Docker ------------------------------------------------
# When calling Docker from PowerShell (not Git Bash), use forward slashes
# but keep the Windows drive letter (e.g. D:/path/...) — NOT /d/path/...
$ToolsDirDocker  = $ToolsDir.Replace('\', '/')
$ImagesDirDocker = $ImagesDir.Replace('\', '/')

Write-Host ""
Write-Host "  Thermal images found : $ThermalCount"
Write-Host "  Images folder        : $ImagesDir"
Write-Host "  Tools folder         : $ToolsDir"
Write-Host "  Output               : $ImagesDir\tiff\"
Write-Host ""
Write-Host "  Starting conversion via Docker..."
Write-Host ""

# --- Write bash script to a temp file ----------------------------------------
# This avoids all PowerShell/Docker/bash quoting issues entirely.
# Single-quoted here-string (@'...'@) means no PowerShell variable expansion,
# so all bash $VAR syntax is passed through literally and correctly.
$BashScript = @'
#!/bin/bash
set -e

echo "  [Docker] Installing dependencies..."
apt-get update -qq && apt-get install -y -qq perl libgomp1 > /dev/null 2>&1

echo "  [Docker] Setting permissions..."
chmod +x /tools/rjpeg2tiff /tools/dji_irp /tools/raw2tiff /tools/exiftool

echo "  [Docker] Scanning for thermal images..."
FILES=$(find /images -maxdepth 1 -name '*_T.JPG' -type f)
FILES2=$(find /images -maxdepth 1 -name '*_T.jpg' -type f)
ALL_FILES=$(printf '%s\n' $FILES $FILES2 | sort -u | tr '\n' ' ')
ALL_FILES=$(echo "$ALL_FILES" | xargs)

if [ -z "$ALL_FILES" ]; then
    echo "  [Docker] ERROR: No _T.JPG files found in /images — check volume mount."
    exit 1
fi

COUNT=$(echo "$ALL_FILES" | wc -w)
echo "  [Docker] Creating output folder..."
mkdir -p /images/tiff
cd /images

echo " [Docker] Converting $COUNT thermal images to TIFF..."
/tools/rjpeg2tiff $ALL_FILES
echo "  [Docker] Done."
'@

$TempScript       = Join-Path $env:TEMP "convert_thermal_docker.sh"
$TempScriptDocker = $TempScript.Replace('\', '/')

# Write with Unix line endings (LF only) — required for bash inside Linux container
[System.IO.File]::WriteAllText(
    $TempScript,
    $BashScript.Replace("`r`n", "`n"),
    (New-Object System.Text.UTF8Encoding $false)
)

# --- Run conversion in a Linux Docker container ------------------------------
docker run --rm `
    --platform linux/amd64 `
    -v "${ToolsDirDocker}:/tools" `
    -v "${ImagesDirDocker}:/images" `
    -v "${TempScriptDocker}:/convert.sh" `
    ubuntu:22.04 `
    bash /convert.sh

$dockerExitCode = $LASTEXITCODE

# Clean up temp script
Remove-Item $TempScript -ErrorAction SilentlyContinue

if ($dockerExitCode -eq 0) {
    Write-Host ""
    Write-Host "  Done! Your TIFF files are in:" -ForegroundColor Green
    Write-Host "  $ImagesDir\tiff\" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  Something went wrong (Docker exit code: $dockerExitCode)." -ForegroundColor Red
    Write-Host "  Check the [Docker] messages above for details." -ForegroundColor Red
    Write-Host ""
    exit 1
}
