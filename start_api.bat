@echo off
REM Start the Bingo Event API server
REM Make sure you have .NET SDK installed

echo.
echo ===================================
echo Bingo Event - API Server Startup
echo ===================================
echo.

REM Check if dotnet is installed
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: .NET SDK is not installed or not in PATH
    echo Please install .NET SDK from: https://dotnet.microsoft.com/download
    pause
    exit /b 1
)

REM Change to API folder
cd API_folder

echo Starting API server...
echo Listening on: http://localhost:5000
echo.

REM Run the API
dotnet run

if errorlevel 1 (
    echo ERROR: API startup failed
    pause
    exit /b 1
)
