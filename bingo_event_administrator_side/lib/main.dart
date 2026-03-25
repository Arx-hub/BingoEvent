import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/bingo_api_service.dart';
import 'services/welcome_page_api_service.dart';
import 'services/event_api_service.dart';
import 'minigames/games_registry.dart';

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

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> welcomePages = [];
  List<Map<String, dynamic>> bingoBoards = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        EventAPI.getAllEvents(),
        WelcomePageAPI.getAllWelcomePages(),
        BingoBoardAPI.getAllBoards(),
      ]);
      setState(() {
        events = results[0];
        welcomePages = results[1];
        bingoBoards = results[2];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  String _welcomePageName(int id) {
    final page = welcomePages.where((p) => p['id'] == id).firstOrNull;
    return page != null ? (page['name'] ?? 'Unnamed').toString() : 'Unknown (#$id)';
  }

  String _bingoBoardName(int id) {
    final board = bingoBoards.where((b) => b['id'] == id).firstOrNull;
    return board != null ? (board['name'] ?? 'Unnamed').toString() : 'Unknown (#$id)';
  }

  void _deleteEvent(int index) {
    final evt = events[index];
    final id = evt['id'] as int?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${evt['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (id != null) {
                try {
                  await EventAPI.deleteEvent(id);
                  _loadAll();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _previewEvent(int index) {
    final evt = events[index];
    final wpId = evt['welcomePageId'] as int? ?? 0;
    final bbId = evt['bingoBoardId'] as int? ?? 0;
    final gameNames = evt['gameNames'] is List
        ? List<String>.from((evt['gameNames'] as List).map((e) => e.toString()))
        : <String>[];

    // Find the welcome page and bingo board data
    final wpData = welcomePages.where((p) => p['id'] == wpId).firstOrNull;
    final bbData = bingoBoards.where((b) => b['id'] == bbId).firstOrNull;

    final title = wpData != null ? (wpData['title'] ?? '').toString() : 'Welcome!';
    final subtitle = wpData != null ? (wpData['subtitle'] ?? '').toString() : '';
    final boardName = bbData != null ? (bbData['name'] ?? '').toString() : 'Bingo Board';

    List<String> boxes = [];
    if (bbData != null && bbData['boxes'] is List) {
      boxes = (bbData['boxes'] as List).map((e) => e?.toString() ?? '').toList();
    }
    while (boxes.length < 25) {
      boxes.add('');
    }
    boxes = boxes.take(25).toList();

    // Get matching game configs for this event
    final eventGames = GamesRegistry.availableGames
        .where((g) => gameNames.contains(g.name))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPreviewWelcome(
          title: title,
          subtitle: subtitle,
          boardName: boardName,
          boxes: boxes,
          games: eventGames,
        ),
      ),
    );
  }

  void _editEvent(int index) {
    final evt = events[index];
    final gameNames = evt['gameNames'] is List
        ? List<String>.from((evt['gameNames'] as List).map((e) => e.toString()))
        : <String>[];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventEditor(
          existingId: evt['id'] as int?,
          existingName: (evt['name'] ?? '').toString(),
          existingCreator: (evt['creator'] ?? '').toString(),
          existingWelcomePageId: evt['welcomePageId'] as int?,
          existingBingoBoardId: evt['bingoBoardId'] as int?,
          existingGameNames: gameNames,
          welcomePages: welcomePages,
          bingoBoards: bingoBoards,
          onSave: () {
            _loadAll();
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
              onPressed: _loadAll,
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
            child: events.isEmpty
                ? const Center(child: Text('No events created yet.'))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final evt = events[index];
                      final name = (evt['name'] ?? 'Unnamed').toString();
                      final creator = (evt['creator'] ?? '').toString();
                      final wpId = evt['welcomePageId'] as int? ?? 0;
                      final bbId = evt['bingoBoardId'] as int? ?? 0;
                      final gameNames = evt['gameNames'] is List
                          ? (evt['gameNames'] as List).map((e) => e.toString()).toList()
                          : <String>[];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (creator.isNotEmpty) Text('Creator: $creator'),
                              Text('Welcome Page: ${_welcomePageName(wpId)}'),
                              Text('Bingo Board: ${_bingoBoardName(bbId)}'),
                              Text('Mini-Games: ${gameNames.isEmpty ? 'None' : gameNames.join(', ')}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.preview, color: Colors.green),
                                tooltip: 'Preview guest experience',
                                onPressed: () => _previewEvent(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editEvent(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteEvent(index),
                              ),
                            ],
                          ),
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
                  onPressed: _loadAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventEditor(
                          welcomePages: welcomePages,
                          bingoBoards: bingoBoards,
                          onSave: () {
                            _loadAll();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Event'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventEditor extends StatefulWidget {
  final int? existingId;
  final String? existingName;
  final String? existingCreator;
  final int? existingWelcomePageId;
  final int? existingBingoBoardId;
  final List<String>? existingGameNames;
  final List<Map<String, dynamic>> welcomePages;
  final List<Map<String, dynamic>> bingoBoards;
  final VoidCallback onSave;

  const EventEditor({
    super.key,
    this.existingId,
    this.existingName,
    this.existingCreator,
    this.existingWelcomePageId,
    this.existingBingoBoardId,
    this.existingGameNames,
    required this.welcomePages,
    required this.bingoBoards,
    required this.onSave,
  });

  @override
  State<EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  late TextEditingController nameController;
  late TextEditingController creatorController;
  int? selectedWelcomePageId;
  int? selectedBingoBoardId;
  late List<String> selectedGameNames;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingName ?? '');
    creatorController = TextEditingController(text: widget.existingCreator ?? '');
    selectedWelcomePageId = widget.existingWelcomePageId;
    selectedBingoBoardId = widget.existingBingoBoardId;
    selectedGameNames = List<String>.from(widget.existingGameNames ?? []);
  }

  @override
  void dispose() {
    nameController.dispose();
    creatorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event name')),
      );
      return;
    }
    if (selectedWelcomePageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a welcome page')),
      );
      return;
    }
    if (selectedBingoBoardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bingo board')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await EventAPI.saveEvent(
        name: nameController.text,
        creator: creatorController.text,
        welcomePageId: selectedWelcomePageId!,
        bingoBoardId: selectedBingoBoardId!,
        gameNames: selectedGameNames,
        id: widget.existingId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event saved successfully!')),
        );
        widget.onSave();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableGames = GamesRegistry.availableGames;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingId == null ? 'Create Event' : 'Edit Event'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Event Name',
                    hintText: 'Name for this event package',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: creatorController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Creator Name',
                    hintText: 'Who is creating this event',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // Welcome Page dropdown
                DropdownButtonFormField<int>(
                  value: widget.welcomePages.any((p) => p['id'] == selectedWelcomePageId)
                      ? selectedWelcomePageId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Welcome Page',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.welcomePages.map((page) {
                    return DropdownMenuItem<int>(
                      value: page['id'] as int,
                      child: Text((page['name'] ?? 'Unnamed').toString()),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() => selectedWelcomePageId = value);
                        },
                ),
                const SizedBox(height: 16),
                // Bingo Board dropdown
                DropdownButtonFormField<int>(
                  value: widget.bingoBoards.any((b) => b['id'] == selectedBingoBoardId)
                      ? selectedBingoBoardId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Bingo Board',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.bingoBoards.map((board) {
                    return DropdownMenuItem<int>(
                      value: board['id'] as int,
                      child: Text((board['name'] ?? 'Unnamed').toString()),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() => selectedBingoBoardId = value);
                        },
                ),
                const SizedBox(height: 24),
                // Mini-Games checkboxes
                const Text(
                  'Select Mini-Games',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...availableGames.map((game) {
                  final isSelected = selectedGameNames.contains(game.name);
                  return CheckboxListTile(
                    title: Text(game.name),
                    subtitle: Text(game.description),
                    value: isSelected,
                    onChanged: isSaving
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                selectedGameNames.add(game.name);
                              } else {
                                selectedGameNames.remove(game.name);
                              }
                            });
                          },
                  );
                }),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomePageTab extends StatefulWidget {
  const WelcomePageTab({super.key});

  @override
  State<WelcomePageTab> createState() => _WelcomePageTabState();
}

class _WelcomePageTabState extends State<WelcomePageTab> {
  List<Map<String, dynamic>> welcomePages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWelcomePages();
  }

  Future<void> _loadWelcomePages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final pages = await WelcomePageAPI.getAllWelcomePages();
      setState(() {
        welcomePages = pages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load welcome pages: $e';
        isLoading = false;
      });
    }
  }

  void _deleteWelcomePage(int index) {
    final page = welcomePages[index];
    final id = page['id'] as int?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Welcome Page'),
        content: Text('Are you sure you want to delete "${page['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (id != null) {
                try {
                  await WelcomePageAPI.deleteWelcomePage(id);
                  _loadWelcomePages();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editWelcomePage(int index) {
    final page = welcomePages[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomePageEditor(
          existingId: page['id'] as int?,
          existingName: (page['name'] ?? '').toString(),
          existingTitle: (page['title'] ?? '').toString(),
          existingSubtitle: (page['subtitle'] ?? '').toString(),
          onSave: () {
            _loadWelcomePages();
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
              onPressed: _loadWelcomePages,
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
            child: welcomePages.isEmpty
                ? const Center(child: Text('No welcome pages created yet.'))
                : ListView.builder(
                    itemCount: welcomePages.length,
                    itemBuilder: (context, index) {
                      final page = welcomePages[index];
                      final title = (page['title'] ?? '').toString();
                      final subtitle = (page['subtitle'] ?? '').toString();
                      return ListTile(
                        title: Text((page['name'] ?? 'Unnamed').toString()),
                        subtitle: Text(
                          title.isNotEmpty
                              ? 'Title: $title${subtitle.isNotEmpty ? ' | Subtitle: $subtitle' : ''}'
                              : 'No title set',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editWelcomePage(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteWelcomePage(index),
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
                  onPressed: _loadWelcomePages,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WelcomePageEditor(
                          onSave: () {
                            _loadWelcomePages();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Welcome Page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePageEditor extends StatefulWidget {
  final int? existingId;
  final String? existingName;
  final String? existingTitle;
  final String? existingSubtitle;
  final VoidCallback onSave;

  const WelcomePageEditor({
    super.key,
    this.existingId,
    this.existingName,
    this.existingTitle,
    this.existingSubtitle,
    required this.onSave,
  });

  @override
  State<WelcomePageEditor> createState() => _WelcomePageEditorState();
}

class _WelcomePageEditorState extends State<WelcomePageEditor> {
  late TextEditingController nameController;
  late TextEditingController titleController;
  late TextEditingController subtitleController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingName ?? '');
    titleController = TextEditingController(text: widget.existingTitle ?? '');
    subtitleController = TextEditingController(text: widget.existingSubtitle ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a page name')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      await WelcomePageAPI.saveWelcomePage(
        name: nameController.text,
        title: titleController.text,
        subtitle: subtitleController.text,
        id: widget.existingId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome page saved successfully!')),
        );
        widget.onSave();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
        setState(() => isSaving = false);
      }
    }
  }

  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: WelcomePagePreview(
          title: titleController.text,
          subtitle: subtitleController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingId == null ? 'Create Welcome Page' : 'Edit Welcome Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Page Name',
                    hintText: 'Internal name for this welcome page',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Main Title',
                    hintText: 'The big welcome title guests will see',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtitleController,
                  enabled: !isSaving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Subtitle (optional)',
                    hintText: 'Smaller text shown below the main title',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),
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
                      onPressed: isSaving ? null : _save,
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
      ),
    );
  }
}

class WelcomePagePreview extends StatelessWidget {
  final String title;
  final String subtitle;

  const WelcomePagePreview({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade300, Colors.blue.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          // Main title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              title.isEmpty ? 'Welcome!' : title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
          const Spacer(),
          // Simulated "Continue" button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '(Preview - this is how guests will see it)',
            style: TextStyle(fontSize: 11, color: Colors.white54),
          ),
          const SizedBox(height: 12),
        ],
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
    final games = GamesRegistry.availableGames;

    return Scaffold(
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(game.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(game.description),
              trailing: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => game.gamePageBuilder(
                        context,
                        () => Navigator.pop(context),
                        () => Navigator.pop(context),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.preview),
                label: const Text('Preview'),
              ),
            ),
          );
        },
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

// ==================== Event Preview Flow ====================

class EventPreviewWelcome extends StatelessWidget {
  final String title;
  final String subtitle;
  final String boardName;
  final List<String> boxes;
  final List<GameConfig> games;

  const EventPreviewWelcome({
    super.key,
    required this.title,
    required this.subtitle,
    required this.boardName,
    required this.boxes,
    required this.games,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      appBar: AppBar(
        title: const Text('Preview: Welcome Page'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Exit Preview', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade700],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  title.isEmpty ? 'Welcome!' : title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPreviewBingoBoard(
                        boardName: boardName,
                        boxes: boxes,
                        games: games,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '(Preview — this is what the guest sees)',
                style: TextStyle(fontSize: 11, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventPreviewBingoBoard extends StatefulWidget {
  final String boardName;
  final List<String> boxes;
  final List<GameConfig> games;

  const EventPreviewBingoBoard({
    super.key,
    required this.boardName,
    required this.boxes,
    required this.games,
  });

  @override
  State<EventPreviewBingoBoard> createState() => _EventPreviewBingoBoardState();
}

class _EventPreviewBingoBoardState extends State<EventPreviewBingoBoard> {
  late List<bool> checkedBoxes;
  int checkedCount = 0;

  @override
  void initState() {
    super.initState();
    checkedBoxes = List.filled(25, false);
  }

  void _checkWinCondition() {
    // Check rows
    for (int row = 0; row < 5; row++) {
      if (List.generate(5, (col) => checkedBoxes[row * 5 + col]).every((b) => b)) {
        _showBingoWin();
        return;
      }
    }
    // Check columns
    for (int col = 0; col < 5; col++) {
      if (List.generate(5, (row) => checkedBoxes[row * 5 + col]).every((b) => b)) {
        _showBingoWin();
        return;
      }
    }
    // Check diagonals
    if (List.generate(5, (i) => checkedBoxes[i * 5 + i]).every((b) => b) ||
        List.generate(5, (i) => checkedBoxes[i * 5 + (4 - i)]).every((b) => b)) {
      _showBingoWin();
    }
  }

  void _showBingoWin() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 BINGO!'),
        content: const Text('The guest completed a bingo line!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Exit Preview'),
          ),
        ],
      ),
    );
  }

  void _showMiniGame() {
    if (widget.games.isEmpty) return;

    final shuffled = List<GameConfig>.from(widget.games)..shuffle();
    final game = shuffled.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => game.gamePageBuilder(
          context,
          () {
            // On win: pop game, then show win screen with free pick
            Navigator.pop(context);
            _showMinigameWinScreen();
          },
          () {
            // On skip: just pop back to board
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showMinigameWinScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Congratulations!')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text('You Won!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('You get a free pick on the bingo board',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _selectBoxToMark();
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectBoxToMark() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a box to mark'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 6.0,
              mainAxisSpacing: 6.0,
            ),
            itemCount: 25,
            itemBuilder: (context, index) {
              final text = widget.boxes[index];
              return GestureDetector(
                onTap: () {
                  if (!checkedBoxes[index]) {
                    setState(() {
                      checkedBoxes[index] = true;
                      checkedCount++;
                    });
                    Navigator.pop(context);
                    _checkWinCondition();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: checkedBoxes[index] ? Colors.green : Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      text.isEmpty ? 'Box ${index + 1}' : text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onBoxTap(int index) {
    if (checkedBoxes[index]) return;

    setState(() {
      checkedBoxes[index] = true;
      checkedCount++;
    });

    // Every 3 boxes, trigger a minigame (if games are configured)
    if (widget.games.isNotEmpty && checkedCount % 3 == 0) {
      _showMiniGame();
    }

    _checkWinCondition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.boardName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('Exit Preview'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Preview mode — tap boxes to simulate guest play'
                      '${widget.games.isNotEmpty ? " (minigame every 3 taps)" : ""}',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 25,
                  itemBuilder: (context, index) {
                    final text = widget.boxes[index];
                    return GestureDetector(
                      onTap: () => _onBoxTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: checkedBoxes[index] ? Colors.green : Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Center(
                          child: Text(
                            text.isEmpty ? 'Box ${index + 1}' : text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
