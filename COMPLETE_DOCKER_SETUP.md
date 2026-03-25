# Complete Docker Setup with Database Bind Mounts & API

This guide explains the complete setup with the C# API, SQLite database, and Flutter apps all running in Docker with proper database persistence.

## Architecture

```
┌─────────────────────────────────────────┐
│      Docker Compose Network             │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │ bingo-guest  │  │ bingo-admin  │   │
│  │ (Port 8081)  │  │ (Port 8082)  │   │
│  └──────────────┘  └──────────────┘   │
│         ↓                  ↓           │
│  ┌──────────────────────────────┐     │
│  │   bingo-api (Port 5000)      │     │
│  │   .NET 9.0 / SqliteDB        │     │
│  │   ├─ Bind Mount: ./database  │     │
│  │   └─ BingoEvent.db           │     │
│  └──────────────────────────────┘     │
│                                        │
└────────────────────────────────────────┘
```

## Components

### 1. **C# REST API** (bingo-api)
- **Framework:** .NET 9.0 with Entity Framework Core
- **Database:** SQLite (with bind mount for persistence)
- **Port:** 5000
- **Database Location:** `./database/BingoEvent.db` (on host machine)
- **Features:**
  - POST `/api/bingo/hello-world` - Write "Hello World" entry
  - GET `/api/bingo/hello-world` - Retrieve all entries
  - Auto-creates tables on first request
  - Health check endpoint at `/health`

### 2. **Flutter Admin App** (bingo-admin)
- **Port:** 8082
- **Features:**
  - "Hello World Database Test" button in Feedback tab
  - Calls API to write and retrieve entries
  - Displays entries in real-time

### 3. **Flutter Guest App** (bingo-guest)
- **Port:** 8081
- **Status:** Ready for future API integration

## Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Flutter SDK installed locally (for building web versions)
- Postman (optional, for API testing)

### Step 1: Build Flutter Apps

```bash
cd ~/Documents/FunniesForOhke25/BingoEvent

# Build guest app
cd bingo_event_guest_side
flutter pub get
flutter build web --release
cd ..

# Build admin app  
cd bingo_event_administrator_side
flutter pub get
flutter build web --release
cd ..
```

### Step 2: Start All Services

```bash
# From the BingoEvent root directory
docker compose up --build

# Or in background
docker compose up -d --build
```

This single command will start all three services:
- API (port 5000)
- Admin app (port 8082)
- Guest app (port 8081)

### Step 3: Test the Setup

#### Option A: Using the Flutter Admin App UI
1. Open browser: http://localhost:8082
2. Click the "Feedback" tab
3. Click "Write Hello World to Database" button
4. See the result and entries appear in real-time

#### Option B: Using Postman
1. **Write entry:**
   ```
   POST http://localhost:5000/api/bingo/hello-world
   Header: Content-Type: application/json
   Body: (empty or {})
   ```

2. **Read entries:**
   ```
   GET http://localhost:5000/api/bingo/hello-world
   ```

3. **Example Response:**
   ```json
   {
     "success": true,
     "count": 2,
     "entries": [
       {
         "id": 1,
         "message": "Hello World",
         "createdAt": "2026-03-19T10:30:45.1234567Z"
       },
       {
         "id": 2,
         "message": "Hello World",
         "createdAt": "2026-03-19T10:31:12.9876543Z"
       }
     ]
   }
   ```

## Database Persistence (Bind Mounts)

### Directory Structure

```
BingoEvent/
├── docker-compose.yml          # Orchestrates all services
├── database/                   # Bind mount directory (created automatically)
│   └── BingoEvent.db          # SQLite database file persists here
├── API_folder/
│   ├── Dockerfile
│   ├── BingoEvent.db          # Symlinked/mounted to ./database/
│   └── ...
├── bingo_event_guest_side/
│   ├── build/web/             # Pre-built Flutter web app
│   └── ...
└── bingo_event_administrator_side/
    ├── build/web/             # Pre-built Flutter web app
    └── ...
```

### How Bind Mounts Work

**In docker-compose.yml:**
```yaml
volumes:
  - ./database:/app/Data                 # Maps ./database to /app/Data
  - ./API_folder/BingoEvent.db:/app/BingoEvent.db
```

**Benefits:**
- Database persists between container restarts
- Can inspect database from host machine
- Easy backup (just copy the file)
- Data survives container recreation

### Access Database from Host

You can use SQLite tools on your Mac:

```bash
# Using sqlite3 CLI
sqlite3 database/BingoEvent.db

# View tables
.tables

# View hello world entries
SELECT * FROM HelloWorldEntries;

# Count entries
SELECT COUNT(*) FROM HelloWorldEntries;
```

## Postman Testing Guide

### Setup Postman Collection

1. **Create new collection:** "Bingo Event API"

2. **Create requests:**

   a) **Health Check**
   ```
   GET http://localhost:5000/health
   ```

   b) **Write Hello World**
   ```
   POST http://localhost:5000/api/bingo/hello-world
   Content-Type: application/json
   
   (no body required)
   ```

   c) **Get All Entries**
   ```
   GET http://localhost:5000/api/bingo/hello-world
   Content-Type: application/json
   ```

3. **Test flow:**
   - First, verify the API is healthy
   - Click "Write Hello World" button in admin app (or POST in Postman)
   - Use GET request to verify entry was written
   - Repeat multiple times
   - Refresh admin app to see updated list

## API Endpoint Details

### Write Hello World
```
POST /api/bingo/hello-world

Response (200 OK):
{
  "success": true,
  "message": "Hello World written to database successfully",
  "entryId": 1,
  "createdAt": "2026-03-19T10:30:45.1234567Z",
  "message_content": "Hello World"
}

Response (500 Error):
{
  "success": false,
  "message": "Error writing to database",
  "error": "exception details"
}
```

### Get All Entries
```
GET /api/bingo/hello-world

Response (200 OK):
{
  "success": true,
  "count": 3,
  "entries": [
    {
      "id": 1,
      "message": "Hello World",
      "createdAt": "2026-03-19T10:30:45.1234567Z"
    },
    ...
  ]
}
```

## File Structure Changes

### Added/Modified Files

```
BingoEvent/
├── docker-compose.yml                    # ✨ NEW - Root orchestration
├── database/                             # ✨ NEW - Database volume
│   └── BingoEvent.db
│
├── API_folder/
│   ├── Dockerfile                        # ✨ NEW - .NET Build
│   ├── Controllers/BingoController.cs    # ✅ UPDATED - Added endpoints
│   ├── Data/BingoContext.cs              # ✅ UPDATED - Added HelloWorldEntry
│   └── Program.cs                        # (unchanged)
│
├── bingo_event_administrator_side/
│   ├── lib/main.dart                     # ✅ UPDATED - Added Hello World UI
│   ├── pubspec.yaml                      # ✅ UPDATED - Added http package
│   ├── docker-compose.yml                # (unchanged, still works standalone)
│   └── Dockerfile                        # (unchanged)
│
└── bingo_event_guest_side/
    ├── docker-compose.yml                # (unchanged)
    └── Dockerfile                        # (unchanged)
```

## Troubleshooting

### API Container Won't Start

```bash
# View logs
docker logs -f bingo_api_container

# Common issues:
# - .NET SDK not found: check Dockerfile FROM image
# - Port 5000 in use: change port in docker-compose.yml
# - Database connection: check connection string in appsettings.json
```

### Database Not Persisting

```bash
# Check if database directory exists
ls -la database/

# Check permissions
chmod 755 database/

# View container volume mounts
docker inspect bingo_api_container | grep -A 20 Mounts
```

### Admin App Can't Connect to API

**Symptoms:** Error saying "Error connecting to API"

**Causes & Solutions:**
1. API not running: `docker compose ps` (should show bingo_api_container running)
2. Wrong port: Ensure API is on port 5000
3. Firewall: Check if localhost:5000 is accessible
4. Network issue: Containers on same network (bingo-network)

**Debug:**
```bash
# Test from admin container
docker exec bingo_admin_container curl http://bingo-api:8080/health

# Check network connectivity
docker network inspect bingo-network
```

### Port Already in Use

If ports are already in use, modify `docker-compose.yml`:

```yaml
services:
  bingo-api:
    ports:
      - "5001:8080"      # Change 5000 -> 5001
  
  bingo-admin:
    ports:
      - "8083:80"        # Change 8082 -> 8083
```

Then restart services and update Postman URLs.

## Commands Reference

### Start/Stop Services
```bash
# Start all services (background)
docker compose up -d --build

# Start with logs visible
docker compose up --build

# Stop all services
docker compose down

# Remove everything (images, containers, volumes)
docker compose down -v
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f bingo-api
docker compose logs -f bingo-admin
docker compose logs -f bingo-guest

# Last 50 lines
docker compose logs --tail 50
```

### Manage Containers
```bash
# List running containers
docker compose ps

# List all containers (including stopped)
docker compose ps -a

# Restart specific service
docker compose restart bingo-api

# Rebuild only API
docker compose build bingo-api

# Rebuild and restart
docker compose up --build -d
```

### Database Access
```bash
# Connect to SQLite database on host
sqlite3 database/BingoEvent.db

# Or using container
docker exec -it bingo_api_container sqlite3 /app/BingoEvent.db

# SQL inside sqlite3:
.tables                    # List tables
.schema HelloWorldEntries  # Show schema
SELECT * FROM HelloWorldEntries;
SELECT COUNT(*) FROM HelloWorldEntries;
DELETE FROM HelloWorldEntries;  # Clear data
```

## Performance Notes

- **First start:** May take 1-2 minutes (need to build .NET, pre-built Flutter apps)
- **API response time:** ~100-200ms for database operations
- **Database size:** SQLite uses minimal disk space
- **Memory usage:** API typically uses ~200MB, apps minimal

## Next Steps

1. Add database seed data on startup
2. Add more API endpoints for Events, Games, etc.
3. Integrate API calls in guest app
4. Add authentication/authorization
5. Set up automatic database backups
6. Deploy to cloud (Azure, AWS, etc.)

## Support

For issues, check:
1. Docker logs: `docker compose logs -f`
2. Database: `sqlite3 database/BingoEvent.db`
3. API health: `curl http://localhost:5000/health`
4. Network: `docker network inspect bingo-network`
