# 🚀 Quick Start - 5 Minutes to Hello World

## Step-by-Step Setup

### Step 1: Build Flutter Apps (2 min)
```bash
cd ~/Documents/FunniesForOhke25/BingoEvent

# Guest App
cd bingo_event_guest_side && flutter build web --release && cd ..

# Admin App
cd bingo_event_administrator_side && flutter build web --release && cd ..
```

### Step 2: Start All Services (30 sec)
```bash
docker compose up -d --build
```

### Step 3: Verify Everything Works (1 min)

**Check containers are running:**
```bash
docker compose ps
```

You should see 3 containers all with `Up` status:
- `bingo_api_container`
- `bingo_admin_container`
- `bingo_guest_container`

**Test the API:**
```bash
curl http://localhost:5000/health
```

Should return: `{"Status":"Healthy",...}`

### Step 4: Access the Apps (1 min)

1. **Admin App:** http://localhost:8082
2. **Guest App:** http://localhost:8081
3. **API:** http://localhost:5000

## Using Hello World Button

### In the Admin App

1. Open http://localhost:8082
2. Click **"Feedback"** tab
3. See the **"Hello World Database Test"** panel
4. Click **"Write Hello World to Database"** green button
5. See message: "Success! Entry ID: 1..."
6. Scroll down to see the entry in "Database Entries"
7. Click the button again - new entry appears with ID: 2

### In Postman (Alternative)

**Write entry:**
```bash
curl -X POST http://localhost:5000/api/bingo/hello-world
```

**Read entries:**
```bash
curl http://localhost:5000/api/bingo/hello-world
```

**Or use Postman GUI:**
- POST: http://localhost:5000/api/bingo/hello-world
- GET: http://localhost:5000/api/bingo/hello-world

### Check Database Directly

```bash
# Access SQLite database
sqlite3 database/BingoEvent.db

# Inside sqlite3:
SELECT * FROM HelloWorldEntries;
SELECT COUNT(*) FROM HelloWorldEntries;
```

## What Each Container Does

| Container | Port | Purpose |
|-----------|------|---------|
| bingo-api | 5000 | .NET API that reads/writes database |
| bingo-admin | 8082 | Admin Flutter web app with Hello World button |
| bingo-guest | 8081 | Guest Flutter web app |

## Important Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Orchestrates all 3 containers |
| `database/` | Folder where database file lives (persists between restarts) |
| `API_folder/Dockerfile` | Builds the .NET API |
| `bingo_event_administrator_side/lib/main.dart` | Contains Hello World button code |

## Troubleshooting

### Containers won't start
```bash
# Check logs
docker compose logs

# Check for errors
docker compose logs bingo-api
```

### API returns 500 error
```bash
# View API logs
docker logs -f bingo_api_container

# Check database file exists
ls -la database/
```

### Admin app shows connection error
```bash
# Verify API is running
curl http://localhost:5000/health

# Check container is up
docker compose ps bingo-api
```

### Port already in use
Edit `docker-compose.yml` and change:
- API: `5000:8080` → `5001:8080`
- Admin: `8082:80` → `8083:80`

## Stop Everything
```bash
docker compose down
```

## Clean Up & Restart
```bash
# Stop and remove everything
docker compose down -v

# Start fresh
docker compose up -d --build
```

## What Just Happened?

1. ✅ Created SQLite database (auto-created on first API call)
2. ✅ Added "HelloWorldEntry" table to database
3. ✅ Created REST API endpoints:
   - POST `/api/bingo/hello-world` → Write to database
   - GET `/api/bingo/hello-world` → Read from database
4. ✅ Added "Hello World" button to admin app
5. ✅ Set up Docker bind mount for database persistence
6. ✅ All data persists even if containers restart

## Next Steps

- Modify the button behavior in `bingo_event_administrator_side/lib/main.dart`
- Add more API endpoints for other features
- Connect guest app to API
- Add database migrations as needed
- Deploy to the cloud

## Useful Commands

```bash
# View logs
docker compose logs -f

# Restart services
docker compose restart

# Rebuild specific service
docker compose build bingo-api

# Execute command in container
docker exec bingo_api_container dotnet --version

# Access SQLite in container
docker exec -it bingo_api_container sqlite3 /app/BingoEvent.db

# Stop services
docker compose down
```

---

**Status Check Endpoints:**
- API Health: `http://localhost:5000/health`
- Admin App: `http://localhost:8082`
- Guest App: `http://localhost:8081`
- API Base: `http://localhost:5000/api/bingo`
