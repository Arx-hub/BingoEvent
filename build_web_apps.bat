@echo off
REM Build Flutter web apps for deployment
REM This script builds both the guest and administrator side apps

echo.
echo ===================================
echo Bingo Event - Flutter Web Build
echo ===================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Navigate to guest side and build
echo Building Guest Side App...
cd bingo_event_guest_side
flutter clean
flutter pub get
flutter build web --release
if errorlevel 1 (
    echo ERROR: Guest side build failed
    cd ..
    pause
    exit /b 1
)
cd ..

echo Guest side build complete!
echo Output: bingo_event_guest_side\build\web\
echo.

REM Navigate to admin side and build
echo Building Administrator Side App...
cd bingo_event_administrator_side
flutter clean
flutter pub get
flutter build web --release
if errorlevel 1 (
    echo ERROR: Admin side build failed
    cd ..
    pause
    exit /b 1
)
cd ..

echo Admin side build complete!
echo Output: bingo_event_administrator_side\build\web\
echo.

echo ===================================
echo Build Complete!
echo ===================================
echo.
echo Next steps:
echo 1. Copy the 'build/web' folders to your server's web directory
echo 2. Start the C# API: dotnet run --project API_folder/API_folder.csproj
echo 3. Access the apps from your browser
echo.
pause
