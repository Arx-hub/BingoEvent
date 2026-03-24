import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/bingo_api_service.dart';

void main() {
  runApp(const AdminApp());
}

// Bingo Board Model
class BingoBoard {
  int? databaseId;  // Database ID from API
  String id;  // Local ID for new boards
  String name;
  List<String> boxes; // 25 boxes for 5x5 grid
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isActive;

  BingoBoard({
    this.databaseId,
    required this.id,
    required this.name,
    required this.boxes,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  static BingoBoard empty() {
    return BingoBoard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      boxes: List.filled(25, ''),
    );
  }

  static BingoBoard fromJson(Map<String, dynamic> json) {
    List<String> boxes = [];
    if (json['boxes'] is List) {
      boxes = (json['boxes'] as List).map((e) => e?.toString() ?? '').toList();
    }
    while (boxes.length < 25) {
      boxes.add('');
    }
    boxes = boxes.take(25).toList();

    final int? dbId = json['id'] is int ? json['id'] as int : null;

    return BingoBoard(
      databaseId: dbId,
      id: (dbId ?? DateTime.now().millisecondsSinceEpoch).toString(),
      name: (json['name'] ?? '').toString(),
      boxes: boxes,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
      isActive: json['isActive'] == true,
    );
  }

  BingoBoard copy() {
    return BingoBoard(
      databaseId: databaseId,
      id: id,
      name: name,
      boxes: List<String>.from(boxes),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingo Admin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AdminHomePage(),
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Events'),
              Tab(text: 'Welcome Pages'),
              Tab(text: 'Bingo Boards'),
              Tab(text: 'Mini-Games'),
              Tab(text: 'Feedback'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EventsTab(),
            WelcomePageTab(),
            BingoBoardsTab(),
            MiniGamesTab(),
            FeedbackTab(),
          ],
        ),
      ),
    );
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for event count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Event Package ${index + 1}'),
                  subtitle: Text('Details about Event ${index + 1}'),
                  onTap: () {
                    // Navigate to event details
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewEventPage(),
                  ),
                );
              },
              child: const Text('Create New Event'),
            ),
          ),
        ],
      ),
    );
  }
}

class NewEventPage extends StatelessWidget {
  const NewEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Event Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Creator Name',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Welcome Page 1', child: Text('Welcome Page 1')),
                DropdownMenuItem(value: 'Welcome Page 2', child: Text('Welcome Page 2')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Select Welcome Page',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Bingo Board 1', child: Text('Bingo Board 1')),
                DropdownMenuItem(value: 'Bingo Board 2', child: Text('Bingo Board 2')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Select Bingo Board',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save event logic
              },
              child: const Text('Save Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomePageTab extends StatelessWidget {
  const WelcomePageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for the number of welcome pages
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Welcome Page ${index + 1}'),
                  subtitle: Text('Welcome message for page ${index + 1}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete welcome page logic
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewWelcomePageForm(),
                  ),
                );
              },
              child: const Text('Create New Welcome Page'),
            ),
          ),
        ],
      ),
    );
  }
}

class NewWelcomePageForm extends StatelessWidget {
  const NewWelcomePageForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Welcome Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Welcome Page Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Welcome Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save welcome page logic
              },
              child: const Text('Save Welcome Page'),
            ),
          ],
        ),
      ),
    );
  }
}

class BingoBoardsTab extends StatefulWidget {
  const BingoBoardsTab({super.key});

  @override
  State<BingoBoardsTab> createState() => _BingoBoardsTabState();
}

class _BingoBoardsTabState extends State<BingoBoardsTab> {
  List<BingoBoard> savedBoards = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBoardsFromAPI();
  }

  Future<void> _loadBoardsFromAPI() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final boardsData = await BingoBoardAPI.getAllBoards();
      final boards = boardsData
          .map((data) => BingoBoard.fromJson(data))
          .toList();
      
      setState(() {
        savedBoards = boards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load boards: $e';
        isLoading = false;
      });
    }
  }

  void _deleteBoard(int index) async {
    final board = savedBoards[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Board'),
        content: Text('Are you sure you want to delete "${board.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              if (board.databaseId != null) {
                try {
                  await BingoBoardAPI.deleteBoard(board.databaseId!);
                  setState(() {
                    savedBoards.removeAt(index);
                  });
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting board: $e')),
                    );
                  }
                }
              } else {
                setState(() {
                  savedBoards.removeAt(index);
                });
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editBoard(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewBingoBoardForm(
          board: savedBoards[index],
          onSave: (updatedBoard) {
            setState(() {
              savedBoards[index] = updatedBoard;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBoardsFromAPI,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: savedBoards.isEmpty
                ? const Center(
                    child: Text('No bingo boards created yet.'),
                  )
                : ListView.builder(
                    itemCount: savedBoards.length,
                    itemBuilder: (context, index) {
                      final board = savedBoards[index];
                      return ListTile(
                        title: Text(board.name),
                        subtitle: Text('Boxes: ${board.boxes.where((b) => b.isNotEmpty).length}/25'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editBoard(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBoard(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadBoardsFromAPI,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewBingoBoardForm(
                          onSave: (newBoard) {
                            setState(() {
                              savedBoards.add(newBoard);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Board'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewBingoBoardForm extends StatefulWidget {
  final BingoBoard? board;
  final Function(BingoBoard) onSave;

  const NewBingoBoardForm({
    super.key,
    this.board,
    required this.onSave,
  });

  @override
  State<NewBingoBoardForm> createState() => _NewBingoBoardFormState();
}

class _NewBingoBoardFormState extends State<NewBingoBoardForm> {
  late BingoBoard currentBoard;
  late TextEditingController boardNameController;
  late List<TextEditingController> boxControllers;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    currentBoard = widget.board?.copy() ?? BingoBoard.empty();
    boardNameController = TextEditingController(text: currentBoard.name);
    boxControllers = List.generate(
      25,
      (index) => TextEditingController(text: currentBoard.boxes[index]),
    );
  }

  @override
  void dispose() {
    boardNameController.dispose();
    for (var controller in boxControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveBoard() async {
    print('[SaveBoard] Starting save. Name: "${boardNameController.text}", databaseId: ${currentBoard.databaseId}');
    
    if (boardNameController.text.isEmpty) {
      print('[SaveBoard] Name is empty, aborting save');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a board name')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      currentBoard.name = boardNameController.text;
      for (int i = 0; i < 25; i++) {
        currentBoard.boxes[i] = boxControllers[i].text;
      }

      print('[SaveBoard] Calling API with ${currentBoard.boxes.where((b) => b.isNotEmpty).length} non-empty boxes');

      // Save to API
      final response = await BingoBoardAPI.saveBoard(
        name: currentBoard.name,
        boxes: currentBoard.boxes,
        id: currentBoard.databaseId,
      );

      // Update databaseId from API response (needed for edit/delete to work)
      if (response['boardId'] != null) {
        currentBoard.databaseId = response['boardId'] as int;
      }

      if (mounted) {
        // Show success message BEFORE onSave pops the navigator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Board saved successfully!')),
        );
        widget.onSave(currentBoard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving board: $e')),
        );
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: BingoBoardPreview(board: currentBoard, boxControllers: boxControllers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.board == null ? 'Create New Bingo Board' : 'Edit Bingo Board'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: 350,
                child: TextField(
                  controller: boardNameController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Board Name',
                    isDense: false,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SizedBox(
                  width: 900,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // 5x5 grid
                      crossAxisSpacing: 6.0,
                      mainAxisSpacing: 6.0,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 25,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: TextField(
                          controller: boxControllers[index],
                          enabled: !isSaving,
                          maxLines: null,
                          expands: true,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(4.0),
                          ),
                          style: const TextStyle(fontSize: 25),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSaving ? null : _showPreview,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isSaving ? null : _saveBoard,
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BingoBoardPreview extends StatefulWidget {
  final BingoBoard board;
  final List<TextEditingController> boxControllers;

  const BingoBoardPreview({
    super.key,
    required this.board,
    required this.boxControllers,
  });

  @override
  State<BingoBoardPreview> createState() => _BingoBoardPreviewState();
}

class _BingoBoardPreviewState extends State<BingoBoardPreview> {
  late List<bool> selectedBoxes;

  @override
  void initState() {
    super.initState();
    selectedBoxes = List.filled(25, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board Preview'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.board.name.isEmpty ? 'Unnamed Board' : widget.board.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // To adjust preview size, change width and height below (e.g., 650x650, 700x700, etc.)
              SizedBox(
                width: 900,
                height: 900,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 5x5 grid
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: 25,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final text = widget.boxControllers[index].text;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBoxes[index] = !selectedBoxes[index];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedBoxes[index] ? Colors.green : Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              text.isEmpty ? 'Box ${index + 1}' : text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '(Click boxes to test)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniGamesTab extends StatelessWidget {
  const MiniGamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 4, // Placeholder for the number of mini-games
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Game ${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MiniGamePage(gameName: 'Game ${index + 1}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MiniGamePage extends StatelessWidget {
  final String gameName;

  const MiniGamePage({super.key, required this.gameName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameName),
      ),
      body: const Center(
        child: Text('Mini-game content goes here.'),
      ),
    );
  }
}

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
              'Success! Entry ID: ${data['entryId']} - Created at: ${data['createdAt']}';
        });
        // Reload the hello worlds list
        await _loadHelloWorlds();
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _isSuccess = false;
          _message = 'Error: ${data['message'] ?? 'Unknown error'}';
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
          _helloWorlds = data['entries'] ?? [];
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
                                  'ID: ${entry['id']}',
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
                              'Message: ${entry['message']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Created: ${entry['createdAt']}',
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

class NewFeedbackForm extends StatelessWidget {
  const NewFeedbackForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Feedback Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Feedback Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save feedback logic
              },
              child: const Text('Save Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
