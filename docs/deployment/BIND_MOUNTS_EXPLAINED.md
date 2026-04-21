# Database Bind Mounts Explained

## What Are Bind Mounts?

**Bind Mount** = A directory on your computer is directly accessible inside a Docker container, as if it were a shared folder.

### Without Bind Mounts (❌ Data Lost)
```
Host Machine          Docker Container
    |                      |
    |                   Database
    |                   (inside container)
    |                      |
 STOP                    Data Lost!
 Container
```

### With Bind Mounts (✅ Data Persists)
```
Host Machine          Docker Container
    |                      |
database/                 |
  ├─ BingoEvent.db ←──────┼─ /app/BingoEvent.db
    |                      |
 STOP                    Data Saved!
 Container
```

## How It Works in Our Setup

### Configuration (docker-compose.yml)
```yaml
services:
  bingo-api:
    volumes:
      - ./database:/app/Data                 # Bind mount for data
      - ./API_folder/BingoEvent.db:/app/BingoEvent.db
```

This means:
- `./database` (on your Mac) = `/app/Data` (inside container)
- When API saves to database, it's actually saving to your Mac
- If container stops, data is still on your Mac

### Directory Structure
```
BingoEvent/
├── database/                    ← Bind mount folder
│   ├── BingoEvent.db           ← Your actual database file
│   └── (other data files)
│
└── API_folder/
    ├── Dockerfile
    ├── Program.cs
    ├── Data/BingoContext.cs
    └── (source code)
    
Inside Container (/app):
├── Data/                        ← Mounted from ./database
│   └── BingoEvent.db           ← Same file as on host!
├── Program.cs
└── (other files)
```

## Real Example

### Step 1: Start Container
```bash
docker compose up -d
```
- Creates `./database/` folder on your Mac
- Container starts with access to it
- Database file ready to be created

### Step 2: Write Data (via Hello World Button)
```
Admin App → API → SQLite → Writes to /app/BingoEvent.db
                           ↓
                    (Same as ./database/BingoEvent.db)
```

### Step 3: Stop Container
```bash
docker compose down
```
- Container stops
- **Database file remains** in `./database/BingoEvent.db`
- You can inspect it with `sqlite3 database/BingoEvent.db`

### Step 4: Start Container Again
```bash
docker compose up -d
```
- Container reads from existing `./database/BingoEvent.db`
- **All previous data is still there!**
- No data loss

## Accessing Data from Host Machine

### Using SQLite CLI
```bash
# Install sqlite3 (if not already installed)
brew install sqlite

# Connect to the database
sqlite3 database/BingoEvent.db

# SQL commands inside sqlite3:
.tables                                    # List tables
.schema HelloWorldEntries                  # Show structure
SELECT * FROM HelloWorldEntries;           # View data
SELECT COUNT(*) FROM HelloWorldEntries;    # Count entries
INSERT INTO HelloWorldEntries VALUES(...); # Add data
UPDATE HelloWorldEntries SET ...           # Update data
DELETE FROM HelloWorldEntries;             # Clear data
.quit                                      # Exit
```

### Using File Explorer
```bash
# Just browse to the folder
open database/

# Copy/backup the database
cp database/BingoEvent.db database/BingoEvent.db.backup
```

### Data Verification Example

**After clicking "Hello World" button 3 times:**

```bash
$ sqlite3 database/BingoEvent.db

sqlite> SELECT * FROM HelloWorldEntries;
1|Hello World|2026-03-19 10:30:45.123456
2|Hello World|2026-03-19 10:31:12.987654
3|Hello World|2026-03-19 10:32:01.555555

sqlite> SELECT COUNT(*) FROM HelloWorldEntries;
3
```

## Benefits of Bind Mounts

### 1. Data Persistence ✅
- Data survives container restarts
- Data survives container deletion
- Data survives laptop restart

### 2. Easy Backup
```bash
# Backup database
cp database/BingoEvent.db database/BingoEvent.db.backup

# Restore from backup
cp database/BingoEvent.db.backup database/BingoEvent.db
```

### 3. Direct Access
- Inspect database without entering container
- Use SQLite tools on your Mac directly
- Share database with other applications

### 4. Development Friendly
- Modify data while container is running
- See changes immediately in app
- Easy to reset: just delete the file

### 5. Production Ready
- Can use shared storage on servers
- Database accessible from multiple containers
- Easy migration between environments

## Different Types of Volumes

### 1. Bind Mount (What We Use) ✅
```yaml
volumes:
  - ./database:/app/Data     # Host path : Container path
```
**Use When:** You want direct access from host machine

### 2. Named Volume (Alternative)
```yaml
volumes:
  - db_volume:/app/Data
```
**Use When:** You don't need direct access, just persistence

### 3. Anonymous Volume (Not Recommended)
```yaml
volumes:
  - /app/Data
```
**Use When:** Temporary data that doesn't need to persist

## Our Setup (docker-compose.yml)

```yaml
volumes:
  bingo-api:
    volumes:
      - ./database:/app/Data                 # Main database location
      - ./API_folder/BingoEvent.db:/app/BingoEvent.db
```

**Why both?**
- `./database:/app/Data` - For general data directory
- `./API_folder/BingoEvent.db:/app/BingoEvent.db` - Specific database file

**Result:** Database persists on your Mac at `./database/BingoEvent.db`

## Permissions & Ownership

### Check Permissions
```bash
ls -la database/
# Output: -rw-r--r--  1 user  group  1024  Mar 19 10:30 BingoEvent.db
```

### If Permission Denied Error
```bash
# Fix permissions
chmod 755 database/
chmod 644 database/BingoEvent.db

# Or allow all access
chmod 777 database/
```

## Troubleshooting Bind Mounts

| Problem | Solution |
|---------|----------|
| Database file not created | Run POST request first, then check `ls -la database/BingoEvent.db` |
| Permission denied | Run `chmod 777 database/` |
| "Device or resource busy" | Container still using file. Run `docker compose down` first |
| Data not persisting | Check mount is correct: `docker inspect bingo_api_container \| grep -i mounts` |
| File not found in container | Verify path: Check Dockerfile and docker-compose.yml |

## Container Lifecycle with Bind Mount

```
Initial State:
┌─────────────────┐  volume mount  ┌──────────────────┐
│  ./database/    │ ←----------→  │  /app/Data       │
│ (empty on Mac)  │               │ (in container)   │
└─────────────────┘               └──────────────────┘

After First Write:
┌──────────────────────┐  volume mount  ┌──────────────────────┐
│  ./database/         │ ←----------→  │  /app/Data           │
│ ├─ BingoEvent.db    │               │ ├─ BingoEvent.db     │
│ └─ (1 entry)        │               │ └─ (1 entry)         │
└──────────────────────┘               └──────────────────────┘

Container Stops:
┌──────────────────────┐                 [Container Stopped]
│  ./database/         │
│ ├─ BingoEvent.db    │  (Data preserved!)
│ └─ (1 entry)        │
└──────────────────────┘

Container Restarts:
┌──────────────────────┐  volume mount  ┌──────────────────────┐
│  ./database/         │ ←----------→  │  /app/Data           │
│ ├─ BingoEvent.db    │               │ ├─ BingoEvent.db     │
│ └─ (1 entry)        │               │ └─ (1 entry)         │
└──────────────────────┘               └──────────────────────┘
  ↑                                     ↑
Data is back! No loss!
```

## Backup Strategy

### Daily Backup
```bash
# Create timestamped backup
cp database/BingoEvent.db database/BingoEvent.db.$(date +%Y%m%d_%H%M%S).backup
```

### Automated Backup Script
```bash
#!/bin/bash
# save as backup.sh
BACKUP_DIR="database/backups"
mkdir -p $BACKUP_DIR
cp database/BingoEvent.db $BACKUP_DIR/BingoEvent.db.$(date +%Y%m%d_%H%M%S).backup

# Run: bash backup.sh
# Or schedule with cron: 0 * * * * /path/to/backup.sh
```

## Security Considerations

⚠️ **Important:** Bind mounts have host access to container files

### Best Practices
1. Don't store sensitive data in plain SQLite
2. Use file permissions: `chmod 600 database/BingoEvent.db`
3. Backup regularly
4. Use environment variables for secrets (not in files)
5. For production, use encrypted volumes or managed databases

## Summary

- **Bind Mount** = Your folder on Mac ↔ Container folder
- **Database persists** even when container stops
- **Direct access** from your Mac without entering container
- **Easy backup/restore** by copying files
- **Production ready** for data durability

Your setup uses: `./database` on Mac ↔ `/app/Data` in container

Data saved to database is automatically saved to your Mac! 🎉
