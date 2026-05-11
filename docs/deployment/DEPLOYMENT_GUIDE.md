# Bingo Event - Complete Deployment & Setup Guide

## Overview

This guide explains how to get the entire Bingo Event system running **without Docker**. The system consists of:

- **C# ASP.NET Core API** - Backend server (port 5000)
- **Flutter Web Apps** - Frontend applications (guest side and admin side)
- **SQLite Database** - Local database

## Prerequisites

Before starting, ensure you have installed:

1. **.NET SDK 6.0+**
   - Download from: https://dotnet.microsoft.com/download
   - Verify: Open PowerShell and run `dotnet --version`

2. **Flutter SDK**
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify: Open PowerShell and run `flutter --version`

3. **Git** (Optional, for cloning)
   - Download from: https://git-scm.com/

## Project Structure

```
BingoEvent/
├── API_folder/                          # C# Backend API
│   ├── Program.cs                      # API startup configuration
│   ├── Controllers/                    # API endpoints
│   ├── Data/                           # Database context
│   └── appsettings.json               # API configuration
├── bingo_event_guest_side/              # Flutter guest app
│   ├── lib/
│   │   ├── main.dart                  # App entry point
│   │   ├── config/api_config.dart     # API configuration
│   │   ├── services/                  # API service classes
│   │   └── minigames/                 # Game implementations
│   └── pubspec.yaml                   # Flutter dependencies
├── bingo_event_administrator_side/      # Flutter admin app
│   ├── lib/
│   │   ├── main.dart                  # App entry point
│   │   ├── config/api_config.dart     # API configuration
│   │   ├── services/                  # API service classes
│   │   └── minigames/                 # Game implementations
│   └── pubspec.yaml                   # Flutter dependencies
├── database/                            # Database files (created at runtime)
├── start_api.ps1                       # PowerShell script to start API
├── start_api.bat                       # Batch script to start API
├── build_web_apps.ps1                 # PowerShell script to build web apps
└── build_web_apps.bat                 # Batch script to build web apps
```

## Quick Start (5 Minutes)

### Method 1: Using the Build Scripts

#### Step 1: Build the Flutter Web Apps

Open PowerShell in the project root and run:

```powershell
.\build_web_apps.ps1
```

Or use the batch file:

```batch
build_web_apps.bat
```

This will:
- Build the guest side Flutter app
- Build the admin side Flutter app
- Create `build/web/` folders in both directories

#### Step 2: Start the API Server

In a new PowerShell window, run:

```powershell
.\start_api.ps1
```

Or use the batch file:

```batch
start_api.bat
```

You should see:
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5000
```

#### Step 3: Access the Apps

Once the API is running, open your browser and navigate to:

- **Guest App**: Copy and open the HTML file from `bingo_event_guest_side\build\web\index.html`
- **Admin App**: Copy and open the HTML file from `bingo_event_administrator_side\build\web\index.html`

---

## Detailed Setup (Manual Process)

If you prefer to do this manually or the scripts fail, follow these steps:

### Building the Guest App

1. Open PowerShell and navigate to the project root
2. Go to the guest app directory:
   ```powershell
   cd bingo_event_guest_side
   ```

3. Clean previous builds:
   ```powershell
   flutter clean
   ```

4. Install dependencies:
   ```powershell
   flutter pub get
   ```

5. Build for web:
   ```powershell
   flutter build web --release
   ```

6. Navigate back:
   ```powershell
   cd ..
   ```

The built files are now in: `bingo_event_guest_side\build\web\`

### Building the Admin App

Repeat the same process for the admin app:

```powershell
cd bingo_event_administrator_side
flutter clean
flutter pub get
flutter build web --release
cd ..
```

The built files are now in: `bingo_event_administrator_side\build\web\`

### Starting the API Server

1. Open a new PowerShell window in the project root

2. Navigate to the API folder:
   ```powershell
   cd API_folder
   ```

3. Run the API:
   ```powershell
   dotnet run
   ```

4. Wait for the output:
   ```
   info: Microsoft.Hosting.Lifetime[14]
        Now listening on: http://localhost:5000
   ```

The API is now running and ready to accept requests!

### Accessing the Apps

1. The built web apps are in HTML/JavaScript/CSS format
2. You can open them directly in a browser by:
   - **Method A**: Double-click the `index.html` file in Explorer
   - **Method B**: Drag `index.html` into your browser
   - **Method C**: Open the file from browser File menu

Example paths:
- Guest: `C:\Users\<YourUsername>\Documents\GitHub\BingoEvent\bingo_event_guest_side\build\web\index.html`
- Admin: `C:\Users\<YourUsername>\Documents\GitHub\BingoEvent\bingo_event_administrator_side\build\web\index.html`

---

## Server Deployment (PuTTY & Remote Server)

This is what your teachers were setting up. Here's how it works:

### Understanding the Setup

```
Developer Computer          Server Machine (via PuTTY SSH)
┌─────────────────┐        ┌─────────────────────────────┐
│  Your Windows   │        │  Linux/Windows Server       │
│   Computer      │─SSH───▶│  ┌─────────────────────┐    │
│                 │        │  │ C# API (5000)      │    │
│                 │        │  │ SQLite Database    │    │
│                 │        │  ├─────────────────────┤    │
│                 │        │  │ Web Server (80/443)│    │
│                 │        │  │ - Serves HTML/CSS │    │
│                 │        │  │ - Proxies /api/*  │    │
│                 │        │  └─────────────────────┘    │
└─────────────────┘        └─────────────────────────────┘
```

### Steps for Server Deployment

#### On Your Local Machine:

1. Build the web apps (as described above)

2. Create deployment package:
   ```powershell
   # Copy both build folders
   Copy-Item -Path "bingo_event_guest_side\build\web\*" -Destination "deployment\guest" -Recurse
   Copy-Item -Path "bingo_event_administrator_side\build\web\*" -Destination "deployment\admin" -Recurse
   Copy-Item -Path "API_folder" -Destination "deployment\api" -Recurse
   ```

#### On the Server (via PuTTY SSH):

1. Connect via PuTTY:
   - Host: `<server-ip-address>`
   - Port: `22` (default SSH)
   - Username: `<your-username>`

2. Create directories:
   ```bash
   mkdir -p /opt/bingo-event/api
   mkdir -p /opt/bingo-event/web/guest
   mkdir -p /opt/bingo-event/web/admin
   ```

3. Upload files (use SCP or FileZilla):
   - Upload `API_folder/*` to `/opt/bingo-event/api/`
   - Upload `bingo_event_guest_side/build/web/*` to `/opt/bingo-event/web/guest/`
   - Upload `bingo_event_administrator_side/build/web/*` to `/opt/bingo-event/web/admin/`

4. Start the API (via PuTTY):
   ```bash
   cd /opt/bingo-event/api
   dotnet run --urls "http://0.0.0.0:5000"
   ```

5. Set up a web server (nginx):
   ```bash
   sudo apt install nginx
   ```

   Create `/etc/nginx/sites-available/bingo-event`:
   ```nginx
   server {
       listen 80;
       server_name _;

       # Guest app
       location /guest/ {
           alias /opt/bingo-event/web/guest/;
           try_files $uri $uri/ /index.html;
       }

       # Admin app
       location /admin/ {
           alias /opt/bingo-event/web/admin/;
           try_files $uri $uri/ /index.html;
       }

       # API proxy
       location /api/ {
           proxy_pass http://localhost:5000/api/;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

   Enable and restart:
   ```bash
   sudo ln -s /etc/nginx/sites-available/bingo-event /etc/nginx/sites-enabled/
   sudo systemctl restart nginx
   ```

6. Access from browser:
   - Guest: `http://<server-ip>/guest/`
   - Admin: `http://<server-ip>/admin/`

---

## API Configuration

The API is configured in `API_folder/Program.cs`:

### CORS Settings (Allows Web Requests)

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

app.UseCors("AllowAll");
```

This allows the web apps (running on different domain/port) to make API calls.

### Database

The API uses SQLite (file-based, no server needed):
- Location: `API_folder/Data/BingoEvent.db`
- Automatically created on first run

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/bingo/boards` | GET | Get all bingo boards |
| `/api/bingo/issue-board` | POST | Create new board |
| `/api/bingo/mark-box` | POST | Mark box on board |
| `/api/auth/login` | POST | Admin login |
| `/api/auth/register` | POST | Create admin account |
| `/api/bingo/events` | GET/POST | Manage events |
| `/api/bingo/published-event` | GET | Get active event (for guests) |

---

## Troubleshooting

### Problem: "API is not running" Error

**Solution:**
1. Make sure the API is running: Open PowerShell and verify it's listening on `http://localhost:5000`
2. Check port 5000 is not in use: 
   ```powershell
   netstat -ano | findstr :5000
   ```
3. Kill the process and restart

### Problem: "Cannot connect to API" from Browser

**Solution:**
1. Check your browser console for CORS errors
2. Verify API is running locally
3. For web: API must be on same port or have CORS enabled (already configured)

### Problem: Flutter Build Failed

**Solution:**
1. Ensure Flutter is up to date:
   ```powershell
   flutter upgrade
   ```
2. Clean everything:
   ```powershell
   flutter clean
   flutter pub get
   ```
3. Try building again

### Problem: Database File Not Found

**Solution:**
1. The database is created automatically on first API run
2. Check `API_folder/Data/` folder exists and has write permissions
3. Run the API once to initialize

---

## API Environment Detection

The apps automatically detect their environment:

- **Local Development** (clicking HTML locally):
  - Guest/Admin apps detect localhost
  - API URL: `http://localhost:5000/api/bingo`

- **Server Deployment**:
  - Apps detect server domain
  - API URL: `/api/bingo` (relative, proxied by nginx)

This is configured in `lib/config/api_config.dart`.

---

## Next Steps

1. **Customize the Event**: Edit bingo boards, welcome messages, and games in the admin app
2. **Deploy to Server**: Follow the "Server Deployment" section
3. **Use PuTTY**: Connect to server via SSH to manage the deployment
4. **Monitor Logs**: Check API and nginx logs for errors

---

## Support

For issues:
1. Check error messages in browser console (F12)
2. Check API logs in PowerShell window
3. Verify .NET and Flutter installations
4. Ensure ports 5000 and 80/443 are not blocked

---

**Last Updated**: April 2026
