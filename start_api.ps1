# Start the Bingo Event API server
# Make sure you have .NET SDK installed

Write-Host ""
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Bingo Event - API Server Startup" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check if dotnet is installed
try {
    dotnet --version | Out-Null
} catch {
    Write-Host "ERROR: .NET SDK is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install .NET SDK from: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Change to API folder
Set-Location API_folder

Write-Host "Starting API server..." -ForegroundColor Yellow
Write-Host "Listening on: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""

# Run the API
& dotnet run

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: API startup failed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
