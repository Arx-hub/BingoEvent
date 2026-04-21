# Postman Testing Guide - Hello World API

## API Endpoint

**Base URL:** `http://localhost:5000/api/bingo`

## Requests

### 1. Health Check (Verify API is running)

```
GET http://localhost:5000/health

Response:
{
  "status": "Healthy",
  "timestamp": "2026-03-19T10:30:45.1234567Z"
}
```

### 2. Write "Hello World" to Database

```
POST http://localhost:5000/api/bingo/hello-world

Headers:
Content-Type: application/json

Body: (empty - just send POST request)

Response (Success - 200 OK):
{
  "success": true,
  "message": "Hello World written to database successfully",
  "entryId": 1,
  "createdAt": "2026-03-19T10:30:45.1234567Z",
  "message_content": "Hello World"
}

Response (Error - 500):
{
  "success": false,
  "message": "Error writing to database",
  "error": "Specific error message"
}
```

### 3. Get All "Hello World" Entries

```
GET http://localhost:5000/api/bingo/hello-world

Headers:
Content-Type: application/json

Body: (empty)

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
    {
      "id": 2,
      "message": "Hello World",
      "createdAt": "2026-03-19T10:31:12.9876543Z"
    },
    {
      "id": 3,
      "message": "Hello World",
      "createdAt": "2026-03-19T10:32:01.5555555Z"
    }
  ]
}
```

## Postman Collection JSON

Copy this into Postman to import the collection:

```json
{
  "info": {
    "_postman_id": "bingo-event-api",
    "name": "Bingo Event API",
    "description": "API for testing Hello World database functionality",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "header": [],
        "url": {
          "raw": "http://localhost:5000/health",
          "protocol": "http",
          "host": ["localhost"],
          "port": "5000",
          "path": ["health"]
        }
      }
    },
    {
      "name": "Write Hello World",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{}"
        },
        "url": {
          "raw": "http://localhost:5000/api/bingo/hello-world",
          "protocol": "http",
          "host": ["localhost"],
          "port": "5000",
          "path": ["api", "bingo", "hello-world"]
        }
      }
    },
    {
      "name": "Get All Hello Worlds",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "url": {
          "raw": "http://localhost:5000/api/bingo/hello-world",
          "protocol": "http",
          "host": ["localhost"],
          "port": "5000",
          "path": ["api", "bingo", "hello-world"]
        }
      }
    }
  ]
}
```

## How to Use in Postman

1. **Import Collection:**
   - Open Postman
   - Click "Import"
   - Select "Raw text" tab
   - Paste the JSON above
   - Click "Import"

2. **Send Requests:**
   - Select "Health Check" → Click "Send"
   - Select "Write Hello World" → Click "Send"
   - Select "Get All Hello Worlds" → Click "Send"
   - Verify entries appear

3. **Add to Tests:**
   - Go to "Tests" tab
   - Add assertions:
   ```javascript
   pm.test("Status is 200", function () {
       pm.response.to.have.status(200);
   });
   
   pm.test("Response has success property", function () {
       var jsonData = pm.response.json();
       pm.expect(jsonData).to.have.property('success');
   });
   ```

## Testing Workflow

1. **Verify API is running:**
   ```
   GET http://localhost:5000/health
   ```
   Should return status 200 with "Healthy"

2. **Write 3 entries:**
   ```
   POST http://localhost:5000/api/bingo/hello-world
   ```
   Repeat 3 times, note the entry IDs returned

3. **Verify entries in database:**
   ```
   GET http://localhost:5000/api/bingo/hello-world
   ```
   Should show all 3 entries with timestamps

4. **Check database file directly:**
   ```bash
   sqlite3 database/BingoEvent.db
   SELECT * FROM HelloWorldEntries;
   SELECT COUNT(*) FROM HelloWorldEntries;
   ```

## Common Issues

| Issue | Solution |
|-------|----------|
| `Connection refused` | API not running. Run: `docker compose ps` |
| `Cannot GET /health` | Wrong endpoint URL. Check it's `/health` not `/api/health` |
| `500 Internal Server Error` | Database issue. Check Docker logs: `docker compose logs -f bingo-api` |
| `No entries returned` | Database not initialized yet. Make a POST request first. |
| `CORS error in browser` | Nginx is serving, but Flutter app needs CORS. Already configured. |

## Expected Flow

```
1. START: docker compose up -d --build
   ↓
2. TEST: GET /health
   ✓ Returns {"status": "Healthy"}
   ↓
3. WRITE: POST /hello-world
   ✓ Returns {"success": true, "entryId": 1}
   ↓
4. READ: GET /hello-world
   ✓ Returns array with 1 entry
   ↓
5. REPEAT: POST /hello-world (2-3 more times)
   ✓ Entry IDs increment (2, 3, 4...)
   ↓
6. VERIFY: GET /hello-world
   ✓ Returns array with all entries
   ↓
7. DATABASE: sqlite3 database/BingoEvent.db
   ✓ SELECT COUNT(*) shows correct count
```

## Response Codes

| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Request successful |
| 500 | Internal Error | Database issue or API crashed |
| N/A | Connection refused | API not running |

## Variables (Optional)

You can set Postman variables for easier testing:

```
{{api_url}} = http://localhost:5000
{{api_path}} = /api/bingo
```

Then use in requests:
```
{{api_url}}{{api_path}}/hello-world
```
