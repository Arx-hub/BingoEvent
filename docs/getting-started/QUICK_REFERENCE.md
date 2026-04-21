# Quick Reference - Bingo Event Setup

## One-Command Quick Start

### Windows PowerShell

```powershell
# Terminal 1: Build web apps
.\build_web_apps.ps1

# Terminal 2: Start API (after build completes)
.\start_api.ps1

# Then: Open browser to the built index.html files
# Guest: bingo_event_guest_side\build\web\index.html
# Admin: bingo_event_administrator_side\build\web\index.html
```

### Windows Command Prompt

```batch
REM Terminal 1: Build web apps
build_web_apps.bat

REM Terminal 2: Start API (after build completes)
start_api.bat

REM Then: Open browser to the built index.html files
```

---

## What Happens When You Build?

```
flutter build web --release
    ↓
Creates: build/web/
    ├── index.html       ← Open this in browser
    ├── main.dart.js
    ├── assets/
    │   ├── fonts/
    │   └── images/
    └── ... other files
```

When you open `index.html`:
1. Browser loads the Flutter web app
2. App initializes and detects it's running locally
3. App sets API URL to `http://localhost:5000/api/bingo`
4. App starts making calls to the backend API

---

## API Must Be Running

For the app to work, the C# API must be running on `http://localhost:5000`

**Terminal 2 (API Server):**
```
dotnet run
    ↓
Now listening on: http://localhost:5000
```

Keep this running while using the app!

---

## Server Deployment (PuTTY)

### On Your Computer:

1. Build: `.\build_web_apps.ps1`
2. Zip both `build/web` folders
3. Transfer to server via SCP

### On Server (via PuTTY SSH):

```bash
# Copy files to web folder
cp -r guest-app /var/www/bingo/guest/
cp -r admin-app /var/www/bingo/admin/

# Start API
cd /opt/bingo-api
dotnet run --urls "http://0.0.0.0:5000"

# Set up nginx (see nginx.conf)
```

### Access from Browser:

- Guest: `http://server-ip/guest/`
- Admin: `http://server-ip/admin/`

---

## Key Files

| File | Purpose |
|------|---------|
| `API_folder/Program.cs` | API setup & CORS config |
| `bingo_event_guest_side/lib/config/api_config.dart` | Guest app API config |
| `bingo_event_administrator_side/lib/config/api_config.dart` | Admin app API config |
| `build_web_apps.ps1` | Build script |
| `start_api.ps1` | API start script |

---

## Ports & URLs

| Service | Port | URL |
|---------|------|-----|
| API | 5000 | http://localhost:5000/api/bingo |
| Web (local) | - | file:///path/to/index.html |
| Web (server) | 80 | http://server-ip/guest/ |

---

## Environment Auto-Detection

The app automatically detects where it's running:

```
If localhost/127.0.0.1
    → API URL = http://localhost:5000/api/bingo

Else (server)
    → API URL = /api/bingo (relative, nginx proxies it)
```

No configuration needed!

---

## Common Commands

### Build Guest App Only
```powershell
cd bingo_event_guest_side
flutter build web --release
cd ..
```

### Build Admin App Only
```powershell
cd bingo_event_administrator_side
flutter build web --release
cd ..
```

### Start API with Custom Port
```powershell
cd API_folder
dotnet run --urls "http://localhost:8080"
cd ..
```

### Check if Port 5000 is in Use
```powershell
netstat -ano | findstr :5000
```

### Kill Process on Port 5000
```powershell
# Find PID from above command
taskkill /PID <PID> /F
```

---

## What If Something Breaks?

### App says "No API available"
→ Make sure `.\start_api.ps1` is running

### Build fails
→ Run `flutter clean` and try again

### Port already in use
→ Kill process with `taskkill` or change port in Program.cs

### CORS error in browser
→ API CORS is already enabled, error is elsewhere

---

**See DEPLOYMENT_GUIDE.md for detailed information**
