import 'package:flutter/material.dart';

void main() {
  runApp(const AdminApp());
}

// Bingo Board Model
class BingoBoard {
  String id;
  String name;
  List<String> boxes; // 25 boxes for 5x5 grid

  BingoBoard({
    required this.id,
    required this.name,
    required this.boxes,
  });

  static BingoBoard empty() {
    return BingoBoard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      boxes: List.filled(25, ''),
    );
  }

  BingoBoard copy() {
    return BingoBoard(
      id: id,
      name: name,
      boxes: List.from(boxes),
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

  void _deleteBoard(int index) {
    setState(() {
      savedBoards.removeAt(index);
    });
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
            child: ElevatedButton(
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
              child: const Text('Create New Bingo Board'),
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

  void _saveBoard() {
    if (boardNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a board name')),
      );
      return;
    }

    currentBoard.name = boardNameController.text;
    for (int i = 0; i < 25; i++) {
      currentBoard.boxes[i] = boxControllers[i].text;
    }

    widget.onSave(currentBoard);
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
                    onPressed: _showPreview,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveBoard,
                    child: const Text('Save'),
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

class FeedbackTab extends StatelessWidget {
  const FeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'Event 1', child: Text('Event 1')),
                DropdownMenuItem(value: 'Event 2', child: Text('Event 2')),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'Select Event',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Placeholder for feedback count
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Feedback ${index + 1} for the selected event.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
