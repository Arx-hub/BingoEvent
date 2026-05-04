# Build Flutter Windows Desktop app for Minigames
# This script builds the guest side app which has been configured as a standalone minigame collection

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Bingo Event - Minigames Desktop Build" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    flutter --version | Out-Null
} catch {
    Write-Host "ERROR: Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Navigate to guest side and build
Write-Host "Building Minigames Desktop App..." -ForegroundColor Yellow
Set-Location bingo_event_guest_side

# Ensure windows is enabled
flutter config --enable-windows-desktop | Out-Null

Write-Host "Cleaning and fetching dependencies..." -ForegroundColor Gray
flutter clean
flutter pub get

Write-Host "Compiling Windows executable (this may take a few minutes)..." -ForegroundColor Yellow
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Desktop build failed" -ForegroundColor Red
    Write-Host "Make sure you have Visual Studio 2022 with 'Desktop development with C++' installed." -ForegroundColor Yellow
    Set-Location ..
    Read-Host "Press Enter to exit"
    exit 1
}
Set-Location ..

# Create a distribution folder
$distDir = "dist_minigames"
if (Test-Path $distDir) {
    Remove-Item -Path $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $distDir | Out-Null

# Copy files to dist folder
Write-Host "Copying files to $distDir..." -ForegroundColor Yellow
$sourceDir = "bingo_event_guest_side\build\windows\x64\runner\Release"
Copy-Item -Path "$sourceDir\*" -Destination $distDir -Recurse

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Windows executable is ready in the '$distDir' folder." -ForegroundColor Cyan
Write-Host "Run '$distDir\bingo_event_guest_side.exe' to play." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press Enter to exit"
