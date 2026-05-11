# Build Flutter web apps for deployment
# This script builds both the guest and administrator side apps

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Bingo Event - Flutter Web Build" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
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
Write-Host "Building Guest Side App..." -ForegroundColor Yellow
Set-Location bingo_event_guest_side
flutter clean
flutter pub get
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Guest side build failed" -ForegroundColor Red
    Set-Location ..
    Read-Host "Press Enter to exit"
    exit 1
}
Set-Location ..

Write-Host "Guest side build complete!" -ForegroundColor Green
Write-Host "Output: bingo_event_guest_side\build\web\" -ForegroundColor Cyan
Write-Host ""

# Navigate to admin side and build
Write-Host "Building Administrator Side App..." -ForegroundColor Yellow
Set-Location bingo_event_administrator_side
flutter clean
flutter pub get
flutter build web --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Admin side build failed" -ForegroundColor Red
    Set-Location ..
    Read-Host "Press Enter to exit"
    exit 1
}
Set-Location ..

Write-Host "Admin side build complete!" -ForegroundColor Green
Write-Host "Output: bingo_event_administrator_side\build\web\" -ForegroundColor Cyan
Write-Host ""

Write-Host "===================================" -ForegroundColor Green
Write-Host "Build Complete!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Copy the 'build/web' folders to your server's web directory"
Write-Host "2. Start the C# API: dotnet run --project API_folder/API_folder.csproj"
Write-Host "3. Access the apps from your browser"
Write-Host ""
Read-Host "Press Enter to exit"
