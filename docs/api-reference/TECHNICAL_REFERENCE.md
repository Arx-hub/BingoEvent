# Technical Reference - Code Changes

## All Code Changes Made

### 1. Database Model Updates

#### File: `API_folder/Data/BingoContext.cs`

**Added property to BingoContext class:**
```csharp
public DbSet<HelloWorldEntry> HelloWorldEntries { get; set; }
```

**Added new entity class:**
```csharp
public class HelloWorldEntry
{
    public int Id { get; set; }
    public string Message { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

---

### 2. API Controller Updates  

#### File: `API_folder/Controllers/BingoController.cs`

**Added imports:**
```csharp
using BingoEvent.API.Data;
using System;
using System.Linq;
using System.Threading.Tasks;
```

**Added dependency injection to constructor:**
```csharp
private readonly BingoContext _dbContext;

public BingoController(BingoContext dbContext)
{
    _dbContext = dbContext;
}
```

**Added health check endpoint:**
```csharp
[HttpGet("/health")]
public IActionResult Health()
{
    return Ok(new { Status = "Healthy", Timestamp = DateTime.UtcNow });
}
```

**Added write endpoint:**
```csharp
/// <summary>
/// POST endpoint to write "Hello World" to the database
/// Automatically creates the HelloWorldEntries table if it doesn't exist
/// </summary>
[HttpPost("hello-world")]
public async Task<IActionResult> WriteHelloWorld()
{
    try
    {
        // Ensure database is created
        await _dbContext.Database.EnsureCreatedAsync();

        // Create new Hello World entry
        var entry = new HelloWorldEntry
        {
            Message = "Hello World",
            CreatedAt = DateTime.UtcNow
        };

        // Add to database
        _dbContext.HelloWorldEntries.Add(entry);
        await _dbContext.SaveChangesAsync();

        return Ok(new
        {
            Success = true,
            Message = "Hello World written to database successfully",
            EntryId = entry.Id,
            CreatedAt = entry.CreatedAt,
            Message_Content = entry.Message
        });
    }
    catch (Exception ex)
    {
        return StatusCode(500, new
        {
            Success = false,
            Message = "Error writing to database",
            Error = ex.Message
        });
    }
}
```

**Added read endpoint:**
```csharp
/// <summary>
/// GET endpoint to retrieve all "Hello World" entries from the database
/// </summary>
[HttpGet("hello-world")]
public async Task<IActionResult> GetHelloWorlds()
{
    try
    {
        // Ensure database is created
        await _dbContext.Database.EnsureCreatedAsync();

        // Get all entries
        var entries = _dbContext.HelloWorldEntries
            .OrderByDescending(e => e.CreatedAt)
            .ToList();

        return Ok(new
        {
            Success = true,
            Count = entries.Count,
            Entries = entries.Select(e => new
            {
                Id = e.Id,
                Message = e.Message,
                CreatedAt = e.CreatedAt
            }).ToList()
        });
    }
    catch (Exception ex)
    {
        return StatusCode(500, new
        {
            Success = false,
            Message = "Error retrieving from database",
            Error = ex.Message
        });
    }
}
```

---

### 3. Flutter Admin App Updates

#### File: `bingo_event_administrator_side/lib/main.dart`

**Added imports:**
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

**Replaced FeedbackTab class with new stateful implementation:**
```dart
class FeedbackTab extends StatefulWidget {
  const FeedbackTab({super.key});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  final String apiUrl = "http://localhost:5000/api/bingo";
  bool _isLoading = false;
  String _message = '';
  bool _isSuccess = false;
  List<dynamic> _helloWorlds = [];

  @override
  void initState() {
    super.initState();
    _loadHelloWorlds();
  }

  Future<void> _writeHelloWorld() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/hello-world'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isSuccess = true;
          _message =
              'Success! Entry ID: ${data['EntryId']} - Created at: ${data['CreatedAt']}';
        });
        // Reload the hello worlds list
        await _loadHelloWorlds();
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _isSuccess = false;
          _message = 'Error: ${data['Message'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      setState(() {
        _isSuccess = false;
        _message =
            'Error connecting to API: $e\n\nMake sure:\n1. API is running on localhost:5000\n2. Docker containers are started\n3. Check CORS settings if running separately';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHelloWorlds() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/hello-world'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _helloWorlds = data['Entries'] ?? [];
        });
      }
    } catch (e) {
      // Silently fail for loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello World Database Test',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'API Endpoint: http://localhost:5000/api/bingo/hello-world\n\n'
                  'POST: Write "Hello World" to database\n'
                  'GET: Retrieve all entries\n\n'
                  'Use Postman to verify:\n'
                  'POST http://localhost:5000/api/bingo/hello-world\n'
                  'GET http://localhost:5000/api/bingo/hello-world',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _writeHelloWorld,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Write Hello World to Database',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                    border: Border.all(
                        color:
                            _isSuccess ? Colors.green : Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color:
                          _isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                      fontSize: 14,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const Text(
                'Database Entries (Last 10)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_helloWorlds.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No entries yet. Click the button above to create one!',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _helloWorlds.length,
                  itemBuilder: (context, index) {
                    final entry = _helloWorlds[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ID: ${entry['Id']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Message: ${entry['Message']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Created: ${entry['CreatedAt']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHelloWorlds,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

---

### 4. Flutter Dependencies

#### File: `bingo_event_administrator_side/pubspec.yaml`

**Added to dependencies section:**
```yaml
http: ^1.1.0
```

---

### 5. Docker Files

#### File: `API_folder/Dockerfile` (NEW)

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /app

# Copy project file
COPY API_folder.csproj ./

# Restore dependencies
RUN dotnet restore

# Copy the rest of the code
COPY . .

# Build the application
RUN dotnet build -c Release -o /app/build

# Publish the application
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0

WORKDIR /app

# Create Data directory for database
RUN mkdir -p /app/Data

# Copy the built application
COPY --from=build /app/publish .

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start the application
ENTRYPOINT ["dotnet", "API_folder.dll"]
```

#### File: `docker-compose.yml` (NEW - Root level)

```yaml
version: '3.8'

services:
  # API Service
  bingo-api:
    build:
      context: ./API_folder
      dockerfile: Dockerfile
    container_name: bingo_api_container
    ports:
      - "5000:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
    volumes:
      # Bind mount for database persistence
      - ./database:/app/Data
      - ./API_folder/BingoEvent.db:/app/BingoEvent.db
    networks:
      - bingo-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 5s

  # Guest Side Service
  bingo-guest:
    build:
      context: ./bingo_event_guest_side
      dockerfile: Dockerfile
    container_name: bingo_guest_container
    ports:
      - "8081:80"
    networks:
      - bingo-network
    environment:
      - API_URL=http://bingo-api:8080/api
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
    depends_on:
      - bingo-api

  # Administrator Side Service
  bingo-admin:
    build:
      context: ./bingo_event_administrator_side
      dockerfile: Dockerfile
    container_name: bingo_admin_container
    ports:
      - "8082:80"
    networks:
      - bingo-network
    environment:
      - API_URL=http://bingo-api:8080/api
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
    depends_on:
      - bingo-api

networks:
  bingo-network:
    driver: bridge

volumes:
  database:
    driver: local
```

---

## Response Examples

### Write Hello World Response (200 OK)
```json
{
  "success": true,
  "message": "Hello World written to database successfully",
  "entryId": 1,
  "createdAt": "2026-03-19T10:30:45.1234567Z",
  "message_content": "Hello World"
}
```

### Write Hello World Response (500 Error)
```json
{
  "success": false,
  "message": "Error writing to database",
  "error": "Specific error details..."
}
```

### Get Hello Worlds Response (200 OK)
```json
{
  "success": true,
  "count": 3,
  "entries": [
    {
      "id": 3,
      "message": "Hello World",
      "createdAt": "2026-03-19T10:32:01.5555555Z"
    },
    {
      "id": 2,
      "message": "Hello World",
      "createdAt": "2026-03-19T10:31:12.9876543Z"
    },
    {
      "id": 1,
      "message": "Hello World",
      "createdAt": "2026-03-19T10:30:45.1234567Z"
    }
  ]
}
```

---

## Integration Points

### Network Communication
- Admin app (port 8082) → API (port 5000)
- Endpoint: `http://bingo-api:8080/api/bingo/hello-world` (internal Docker DNS)
- From host: `http://localhost:5000/api/bingo/hello-world`

### Data Flow
1. User clicks button in admin app
2. Flutter makes HTTP request to API
3. API receives request and validates
4. Database.EnsureCreatedAsync() - creates table if needed
5. New entry created with message and timestamp
6. Saved to SQLite database
7. Bind mount syncs to host filesystem
8. Response returned to app
9. App refreshes entry list
10. Display updated in UI

---

## Testing Summary

| Component | Test | Expected Result |
|-----------|------|-----------------|
| API Health | `curl http://localhost:5000/health` | 200 OK with healthy status |
| Write | `curl -X POST http://localhost:5000/api/bingo/hello-world` | 200 OK with entry ID |
| Read | `curl http://localhost:5000/api/bingo/hello-world` | 200 OK with entries array |
| Admin UI | Click button in feedback tab | Success message appears |
| DB File | `ls -la database/BingoEvent.db` | File exists on host |
| SQL | `sqlite3 database/BingoEvent.db "SELECT COUNT(*)"` | Shows correct count |

All changes maintain backward compatibility with existing code.
