# Flutter Web Build Script - Web Only (Windows PowerShell)
# This script builds the Flutter web application with NO extra platforms
# Usage: .\build_web_only.ps1 (from bingo_event_guest_side directory)

Write-Host "Building Flutter Web Application (Web Only)..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Clean previous build
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
flutter clean

# Build web only - no android, ios, linux, macos, windows
Write-Host "Building web application..." -ForegroundColor Yellow
flutter build web --release --web-renderer=html

Write-Host "Build complete!" -ForegroundColor Green
Write-Host "Web application ready in: build/web/" -ForegroundColor Green
