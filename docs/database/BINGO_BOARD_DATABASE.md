# Bingo Board Database Integration - SQLite

## Overview
This implementation adds SQLite database persistence for Bingo Boards following the same pattern used for the Varasto (Inventory) system.

## Database Schema

### BingoBoards Table
```sql
CREATE TABLE BingoBoards (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Name TEXT NOT NULL,
    CreatedAt TEXT NOT NULL
);
```

### BingoBoardCells Table
```sql
CREATE TABLE BingoBoardCells (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    BingoBoardId INTEGER NOT NULL,
    Row INTEGER NOT NULL,
    Column INTEGER NOT NULL,
    Text TEXT NOT NULL,
    IsMarked INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY(BingoBoardId) REFERENCES BingoBoards(Id) ON DELETE CASCADE
);
```

## API Endpoints

### Create a New Bingo Board
**POST** `/api/bingo/issue-board`

Request:
```json
{
  "boardName": "Event Board 1",
  "textContent": ["Item1", "Item2", "Item3", ..., "Item25"]
}
```

Response:
```json
{
  "success": true,
  "message": "Bingo board created and saved to database successfully.",
  "boardId": 1,
  "boardName": "Event Board 1",
  "board": [[...]]
}
```

### Get All Bingo Boards
**GET** `/api/bingo/boards`

Response:
```json
{
  "success": true,
  "count": 2,
  "boards": [
    {
      "id": 1,
      "name": "Event Board 1",
      "createdAt": "2026-03-24T10:30:00Z"
    },
    ...
  ]
}
```

### Get Specific Bingo Board
**GET** `/api/bingo/board/{boardId}`

Response:
```json
{
  "success": true,
  "board": {
    "id": 1,
    "name": "Event Board 1",
    "createdAt": "2026-03-24T10:30:00Z",
    "content": [[...5x5 array...]],
    "marked": [[...5x5 boolean array...]]
  }
}
```

### Update Cell Text
**PUT** `/api/bingo/update-text`

Request:
```json
{
  "boardId": 1,
  "row": 0,
  "column": 0,
  "newText": "New Item"
}
```

Response:
```json
{
  "success": true,
  "message": "Cell text updated successfully.",
  "cellId": 1,
  "row": 0,
  "column": 0,
  "newText": "New Item"
}
```

### Mark/Unmark Box
**POST** `/api/bingo/mark-box`

Request:
```json
{
  "boardId": 1,
  "row": 0,
  "column": 0
}
```

Response:
```json
{
  "success": true,
  "message": "Box marked successfully.",
  "cellId": 1,
  "row": 0,
  "column": 0,
  "isMarked": true
}
```

## Implementation Details

### Backend Files
- **BingoBoardDb.cs** - Data access class with raw SQLite commands
- **BingoController.cs** - API endpoints (updated to use SQLite)
- **Program.cs** - Dependency injection for BingoBoardDb

### Key Features
✅ All data persisted to SQLite database
✅ Automatic table creation on first run
✅ Foreign key constraints for data integrity
✅ 5x5 board structure
✅ Individual cell tracking (text + marked state)
✅ CORS enabled for Flutter web access

## Building Flutter Web (Web Only)

To avoid downloading unnecessary platform SDKs (Android, iOS, Linux, macOS, Windows), use the provided build scripts:

**Windows PowerShell:**
```powershell
cd bingo_event_guest_side
.\build_web_only.ps1
```

**Linux/macOS:**
```bash
cd bingo_event_guest_side
bash build_web_only.sh
```

Or manually use:
```bash
flutter build web --release --web-renderer=html
```

This will:
- Skip downloading Android SDK, iOS toolchain, etc.
- Build only for web platform
- Output to `build/web/`
- Significantly reduce build time (~80-90% faster)

## Usage Example (Postman/cURL)

### Create a board:
```bash
curl -X POST http://localhost:5000/api/bingo/issue-board \
  -H "Content-Type: application/json" \
  -d '{
    "boardName": "My Bingo Board",
    "textContent": ["One", "Two", "Three", "Four", "Five", ...]
  }'
```

### Get all boards:
```bash
curl http://localhost:5000/api/bingo/boards
```

### Get specific board:
```bash
curl http://localhost:5000/api/bingo/board/1
```

### Mark a box:
```bash
curl -X POST http://localhost:5000/api/bingo/mark-box \
  -H "Content-Type: application/json" \
  -d '{
    "boardId": 1,
    "row": 0,
    "column": 0
  }'
```
