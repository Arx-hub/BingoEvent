# Bingo Event - Setup Troubleshooting Guide

## Installation Issues

### Flutter Not Found

**Error Message:**
```
flutter: The term 'flutter' is not recognized as the name of a cmdlet...
```

**Solution:**
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Add Flutter to PATH:
   - Windows: `C:\src\flutter\bin`
   - Restart PowerShell after adding
3. Verify: `flutter --version`

---

### .NET SDK Not Found

**Error Message:**
```
dotnet: The term 'dotnet' is not recognized...
```

**Solution:**
1. Install .NET SDK: https://dotnet.microsoft.com/download
2. Choose "Run installer" and follow prompts
3. Restart PowerShell after installation
4. Verify: `dotnet --version`

---

## Build Issues

### "flutter: command not found" During Build

**Cause:** Flutter is installed but not in PATH

**Solution:**
```powershell
# Option 1: Add to PATH (permanent)
# Edit Environment Variables → User variables → PATH
# Add: C:\src\flutter\bin

# Option 2: Run directly
C:\src\flutter\bin\flutter build web

# Option 3: Use full path in build script
```

---

### Build Fails with "pub get" Error

**Error Message:**
```
pub get
pub error: The Dart VM service failed to start...
```

**Solution:**
```powershell
cd bingo_event_guest_side
flutter clean
flutter pub cache clean
flutter pub get
flutter build web --release
```

---

### Out of Memory During Build

**Error Message:**
```
java.lang.OutOfMemoryError: Java heap space
```

**Solution (Windows):**
```powershell
# Set Java heap size
$env:GRADLE_OPTS = "-Xmx2048m"

# Then build again
flutter build web --release
```

---

### "No matching package" Error

**Error Message:**
```
Because bingo_event_guest_side depends on http from pub.dev...
```

**Solution:**
1. Delete `pubspec.lock` file
2. Run `flutter pub get` again
3. Verify internet connection is working

---

## Runtime Issues

### API Won't Start

**Error Message:**
```
System.Net.HttpListenerException (48): Address already in use
```

**Solution:**
```powershell
# Find what's using port 5000
netstat -ano | findstr :5000

# Kill the process (replace XXXX with PID)
taskkill /PID XXXX /F

# Try starting API again
.\start_api.ps1
```

---

### Port 5000 Already in Use

**Temporary Fix:**
```powershell
# Use different port
cd API_folder
dotnet run --urls "http://localhost:8080"
```

**Permanent Fix:**
Edit `API_folder/Program.cs`:
```csharp
app.Run("http://localhost:8080");  // Change 5000 to 8080
```

---

### App Can't Connect to API

**Symptoms:**
- App loads but shows "No API available"
- Browser console shows failed requests
- Error: `GET http://localhost:5000/api/bingo... 404`

**Checklist:**
1. ✓ Is `.\start_api.ps1` running?
2. ✓ Is API showing "Now listening on: http://localhost:5000"?
3. ✓ Is port 5000 open: `Test-NetConnection -ComputerName localhost -Port 5000`
4. ✓ Try restarting both API and browser

**Debug Steps:**
```powershell
# 1. Check if port is listening
Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue

# 2. Test API directly
Invoke-WebRequest http://localhost:5000/api/bingo/boards

# 3. Check firewall
# Windows Defender Firewall → Allow app through firewall
# Make sure .NET is allowed
```

---

### CORS Error in Browser

**Error Message:**
```
Access to XMLHttpRequest at 'http://localhost:5000/api/bingo/...' 
from origin 'null' has been blocked by CORS policy
```

**Note:** This error is unusual since CORS is enabled in the API. 

**Possible Causes:**
1. Different port numbers (API on 5000, but app trying 8080)
2. API not restarted after code changes
3. Browser security restrictions

**Solutions:**
```powershell
# 1. Verify API is on correct port
Get-NetTCPConnection -LocalPort 5000

# 2. Check if using web files locally
# Try serving through local web server instead of file://

# 3. Use a local web server
cd bingo_event_guest_side\build\web
python -m http.server 8000
# Then access: http://localhost:8000
```

---

## Database Issues

### Database File Not Found

**Error Message:**
```
System.IO.FileNotFoundException: Could not find file 'BingoEvent.db'
```

**Solution:**
1. API creates `Data/BingoEvent.db` automatically on first run
2. Ensure `API_folder/Data/` directory exists
3. Verify write permissions on `API_folder/` directory
4. Run API once, then try again

---

### Database Locked Error

**Error Message:**
```
SQLite error (5): database is locked
```

**Cause:** Multiple API instances trying to access same database

**Solution:**
```powershell
# Close all API instances
taskkill /IM dotnet.exe /F

# Wait 2 seconds
Start-Sleep -Seconds 2

# Start only one instance
.\start_api.ps1
```

---

### Delete Database and Recreate

```powershell
# Stop API
# Navigate to database
cd API_folder/Data
rm BingoEvent.db
cd ..

# Start API - it will recreate the database
dotnet run
```

---

## Web App Issues

### App Loads Blank Page

**Cause:** `index.html` not found or wrong path

**Solution:**
```powershell
# Verify build exists
Get-ChildItem bingo_event_guest_side\build\web\index.html

# If not found, rebuild
cd bingo_event_guest_side
flutter build web --release
cd ..

# Then open: bingo_event_guest_side\build\web\index.html
```

---

### App Shows "No Event Published"

**This is normal!** The app is looking for an event in the database.

**Solution:**
1. Open admin app
2. Create a welcome page
3. Create a bingo board
4. Create an event and publish it
5. Refresh guest app

---

### Minigames Not Loading

**Error:** Games list is empty or "Game not found"

**Checklist:**
1. ✓ Are games defined in `minigames/games_registry.dart`?
2. ✓ Are game assets in correct folder?
3. ✓ Is API responding to `/api/bingo/question-packages`?

**Debug:**
```powershell
# Test API endpoint
Invoke-WebRequest http://localhost:5000/api/bingo/question-packages
```

---

## PuTTY & Server Issues

### Can't Connect via PuTTY

**Error:** "Connection refused" or "Connection timeout"

**Check:**
1. Is server IP correct?
2. Is SSH port 22 open on server?
3. Is server firewall blocking SSH?

**Solution:**
```bash
# On server: verify SSH is running
sudo systemctl status ssh
sudo systemctl start ssh

# Check SSH port
sudo netstat -tlnp | grep ssh
```

---

### Files Transfer Failed (SCP/SFTP)

**Use FileZilla instead:**
1. Download FileZilla: https://filezilla-project.org/
2. Host: `sftp://server-ip`
3. Port: `22`
4. Username: `your-username`
5. Drag and drop files

---

### Nginx Not Proxying API

**Error:** API requests return 404

**Check Nginx Config:**
```bash
sudo nginx -t  # Test config
sudo systemctl restart nginx  # Restart
sudo systemctl status nginx  # Check status
tail -f /var/log/nginx/error.log  # View errors
```

**Verify Upstream:**
```bash
# Check if API is running
curl http://localhost:5000/api/bingo/boards

# Check nginx proxy
curl http://localhost/api/bingo/boards
```

---

## Common Success Indicators

### API Running Correctly

```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
      Now listening on: https://localhost:5001
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down...
```

### Flutter Build Complete

```
✓ Built build/web/
```

### App Connected to API

```
[DEBUG] API base URL set to: http://localhost:5000/api/bingo
```

---

## Emergency Solutions

### "Just Start Over" Reset

```powershell
# 1. Kill all Node.js/Flutter/dotnet processes
taskkill /F /IM dotnet.exe
taskkill /F /IM flutter.exe

# 2. Clean everything
cd bingo_event_guest_side
flutter clean
cd ..

cd bingo_event_administrator_side
flutter clean
cd ..

# 3. Delete database
rm API_folder/Data/BingoEvent.db

# 4. Start fresh
.\build_web_apps.ps1
.\start_api.ps1
```

---

## Getting Help

When asking for help, provide:
1. Error message (full text)
2. What were you trying to do?
3. Operating system and version
4. .NET version: `dotnet --version`
5. Flutter version: `flutter --version`
6. Have you read DEPLOYMENT_GUIDE.md?

---

**Last Updated:** April 2026
