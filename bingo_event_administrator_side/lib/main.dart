import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'services/bingo_api_service.dart';
import 'services/welcome_page_api_service.dart';
import 'services/event_api_service.dart';
import 'services/question_package_api_service.dart';
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
      length: 6, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Events'),
              Tab(text: 'Welcome Pages'),
              Tab(text: 'Bingo Boards'),
              Tab(text: 'Question Packages'),
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
            QuestionPackagesTab(),
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
  List<Map<String, dynamic>> questionPackages = [];
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
        QuestionPackageAPI.getAllQuestionPackages(),
      ]);
      setState(() {
        events = results[0];
        welcomePages = results[1];
        bingoBoards = results[2];
        questionPackages = results[3];
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

  String _questionPackageName(int? id) {
    if (id == null) return 'None';
    final pkg = questionPackages.where((p) {
      final pId = p['id'];
      return pId != null && pId.toString() == id.toString();
    }).firstOrNull;
    return pkg != null ? (pkg['name'] ?? 'Unnamed').toString() : 'Unknown (#$id)';
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

  void _previewEvent(int index) async {
    // Refresh data to get latest question packages before preview
    await _loadAll();
    if (!mounted) return;

    final evt = events[index];
    final wpId = evt['welcomePageId'] as int? ?? 0;
    final bbId = evt['bingoBoardId'] as int? ?? 0;
    final qpId = evt['questionPackageId'] as int?;
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

    // Get question package data if assigned
    List<Map<String, dynamic>>? eventQuestions;
    if (qpId != null) {
      final qpData = questionPackages.where((p) {
        final pId = p['id'];
        return pId != null && pId.toString() == qpId.toString();
      }).firstOrNull;
      if (qpData != null && qpData['questions'] is List) {
        eventQuestions = List<Map<String, dynamic>>.from(
          (qpData['questions'] as List).map((q) => Map<String, dynamic>.from(q)),
        );
      }
      print('Preview: qpId=$qpId, found package=${qpData != null}, questions=${eventQuestions?.length ?? 0}');
    } else {
      print('Preview: No question package assigned to this event');
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPreviewWelcome(
          title: title,
          subtitle: subtitle,
          boardName: boardName,
          boxes: boxes,
          games: eventGames,
          questions: eventQuestions,
        ),
      ),
    );
  }

  void _editEvent(int index) async {
    // Refresh data to get latest question packages
    await _loadAll();
    if (!mounted) return;

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
          existingQuestionPackageId: evt['questionPackageId'] as int?,
          welcomePages: welcomePages,
          bingoBoards: bingoBoards,
          questionPackages: questionPackages,
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
                      final qpId = evt['questionPackageId'] as int?;

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
                              Text('Question Package: ${_questionPackageName(qpId)}'),
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
                          questionPackages: questionPackages,
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
  final int? existingQuestionPackageId;
  final List<Map<String, dynamic>> welcomePages;
  final List<Map<String, dynamic>> bingoBoards;
  final List<Map<String, dynamic>> questionPackages;
  final VoidCallback onSave;

  const EventEditor({
    super.key,
    this.existingId,
    this.existingName,
    this.existingCreator,
    this.existingWelcomePageId,
    this.existingBingoBoardId,
    this.existingGameNames,
    this.existingQuestionPackageId,
    required this.welcomePages,
    required this.bingoBoards,
    required this.questionPackages,
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
  int? selectedQuestionPackageId;
  late List<String> selectedGameNames;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingName ?? '');
    creatorController = TextEditingController(text: widget.existingCreator ?? '');
    selectedWelcomePageId = widget.existingWelcomePageId;
    selectedBingoBoardId = widget.existingBingoBoardId;
    selectedQuestionPackageId = widget.existingQuestionPackageId;
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
        questionPackageId: selectedQuestionPackageId,
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
                const SizedBox(height: 24),
                // Question Package dropdown
                DropdownButtonFormField<int?>(
                  value: widget.questionPackages.any((p) => p['id'] == selectedQuestionPackageId)
                      ? selectedQuestionPackageId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Question Package (for trivia challenge)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...widget.questionPackages.map((pkg) {
                      final isDefault = pkg['isDefault'] == true;
                      return DropdownMenuItem<int?>(
                        value: pkg['id'] as int,
                        child: Row(
                          children: [
                            if (isDefault) const Icon(Icons.star, size: 16, color: Colors.amber),
                            if (isDefault) const SizedBox(width: 4),
                            Text((pkg['name'] ?? 'Unnamed').toString()),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() => selectedQuestionPackageId = value);
                        },
                ),
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

// ==================== Question Packages Tab ====================

class QuestionPackagesTab extends StatefulWidget {
  const QuestionPackagesTab({super.key});

  @override
  State<QuestionPackagesTab> createState() => _QuestionPackagesTabState();
}

class _QuestionPackagesTabState extends State<QuestionPackagesTab> {
  List<Map<String, dynamic>> packages = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final pkgs = await QuestionPackageAPI.getAllQuestionPackages();
      setState(() {
        packages = pkgs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load question packages: $e';
        isLoading = false;
      });
    }
  }

  void _deletePackage(int index) {
    final pkg = packages[index];
    final id = pkg['id'] as int?;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question Package'),
        content: Text('Are you sure you want to delete "${pkg['name']}"?'),
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
                  await QuestionPackageAPI.deleteQuestionPackage(id);
                  _loadPackages();
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

  void _duplicatePackage(int index) async {
    final pkg = packages[index];
    final id = pkg['id'] as int?;
    if (id == null) return;

    try {
      await QuestionPackageAPI.duplicateQuestionPackage(id);
      _loadPackages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package duplicated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating: $e')),
        );
      }
    }
  }

  void _previewPackage(int index) {
    final pkg = packages[index];
    final questions = pkg['questions'] is List
        ? List<Map<String, dynamic>>.from(
            (pkg['questions'] as List).map((q) => Map<String, dynamic>.from(q)))
        : <Map<String, dynamic>>[];

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This package has no questions to preview')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QuestionPackagePreviewPage(
          packageName: (pkg['name'] ?? 'Unnamed').toString(),
          questions: questions,
        ),
      ),
    );
  }

  void _editPackage(int index) {
    final pkg = packages[index];
    final questions = pkg['questions'] is List
        ? List<Map<String, dynamic>>.from(
            (pkg['questions'] as List).map((q) => Map<String, dynamic>.from(q)))
        : <Map<String, dynamic>>[];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionPackageEditor(
          existingId: pkg['id'] as int?,
          existingName: (pkg['name'] ?? '').toString(),
          existingQuestions: questions,
          existingPackageNames: packages
              .where((p) => p['id'] != pkg['id'])
              .map((p) => (p['name'] ?? '').toString())
              .toList(),
          onSave: () {
            _loadPackages();
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
            ElevatedButton(onPressed: _loadPackages, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: packages.isEmpty
                ? const Center(child: Text('No question packages created yet.'))
                : ListView.builder(
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final pkg = packages[index];
                      final name = (pkg['name'] ?? 'Unnamed').toString();
                      final isDefault = pkg['isDefault'] == true;
                      final questionCount = pkg['questions'] is List
                          ? (pkg['questions'] as List).length
                          : 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: isDefault
                              ? const Icon(Icons.star, color: Colors.amber, size: 28)
                              : const Icon(Icons.quiz, color: Colors.blue, size: 28),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              if (isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('Default',
                                      style: TextStyle(fontSize: 11, color: Colors.amber)),
                                ),
                            ],
                          ),
                          subtitle: Text('$questionCount question${questionCount != 1 ? 's' : ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.preview, color: Colors.green),
                                tooltip: 'Preview',
                                onPressed: () => _previewPackage(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.orange),
                                tooltip: 'Duplicate',
                                onPressed: () => _duplicatePackage(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () => _editPackage(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () => _deletePackage(index),
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
                  onPressed: _loadPackages,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionPackageEditor(
                          existingPackageNames: packages
                              .map((p) => (p['name'] ?? '').toString())
                              .toList(),
                          onSave: () {
                            _loadPackages();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Package'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Question Package Editor ====================

class QuestionPackageEditor extends StatefulWidget {
  final int? existingId;
  final String? existingName;
  final List<Map<String, dynamic>>? existingQuestions;
  final List<String> existingPackageNames;
  final VoidCallback onSave;

  const QuestionPackageEditor({
    super.key,
    this.existingId,
    this.existingName,
    this.existingQuestions,
    required this.existingPackageNames,
    required this.onSave,
  });

  @override
  State<QuestionPackageEditor> createState() => _QuestionPackageEditorState();
}

class _QuestionPackageEditorState extends State<QuestionPackageEditor> {
  late TextEditingController nameController;
  late List<_QuestionData> questions;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingName ?? '');

    if (widget.existingQuestions != null && widget.existingQuestions!.isNotEmpty) {
      questions = widget.existingQuestions!.map((q) {
        return _QuestionData(
          questionController: TextEditingController(text: (q['questionText'] ?? '').toString()),
          answer1Controller: TextEditingController(text: (q['answer1'] ?? '').toString()),
          answer2Controller: TextEditingController(text: (q['answer2'] ?? '').toString()),
          answer3Controller: TextEditingController(text: (q['answer3'] ?? '').toString()),
          correctAnswer: (q['correctAnswer'] is int ? q['correctAnswer'] as int : 1),
        );
      }).toList();
    } else {
      questions = [_QuestionData.empty()];
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    for (final q in questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    if (questions.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 questions per package')),
      );
      return;
    }
    setState(() {
      questions.add(_QuestionData.empty());
    });
  }

  void _removeQuestion(int index) {
    if (questions.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Must have at least one question')),
      );
      return;
    }
    setState(() {
      questions[index].dispose();
      questions.removeAt(index);
    });
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a package name')),
      );
      return;
    }

    // Check duplicate name
    if (widget.existingPackageNames.contains(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A package with this name already exists')),
      );
      return;
    }

    // Validate questions
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      if (q.questionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1} text is empty')),
        );
        return;
      }
      if (q.answer1Controller.text.trim().isEmpty ||
          q.answer2Controller.text.trim().isEmpty ||
          q.answer3Controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All answers for question ${i + 1} are required')),
        );
        return;
      }
    }

    setState(() => isSaving = true);

    try {
      final questionsList = questions.map((q) => {
        'questionText': q.questionController.text.trim(),
        'answer1': q.answer1Controller.text.trim(),
        'answer2': q.answer2Controller.text.trim(),
        'answer3': q.answer3Controller.text.trim(),
        'correctAnswer': q.correctAnswer,
      }).toList();

      await QuestionPackageAPI.saveQuestionPackage(
        name: name,
        questions: questionsList,
        id: widget.existingId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question package saved!')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingId == null ? 'Create Question Package' : 'Edit Question Package'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Package Name',
                    hintText: 'e.g., ICT Trivia',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Questions (${questions.length}/20)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...List.generate(questions.length, (index) {
                  final q = questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                tooltip: 'Remove question',
                                onPressed: isSaving ? null : () => _removeQuestion(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: q.questionController,
                            enabled: !isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Question',
                              hintText: 'Enter the question',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: q.answer1Controller,
                            enabled: !isSaving,
                            decoration: InputDecoration(
                              labelText: 'Answer 1',
                              border: const OutlineInputBorder(),
                              suffixIcon: Radio<int>(
                                value: 1,
                                groupValue: q.correctAnswer,
                                onChanged: isSaving
                                    ? null
                                    : (val) {
                                        setState(() => q.correctAnswer = val!);
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: q.answer2Controller,
                            enabled: !isSaving,
                            decoration: InputDecoration(
                              labelText: 'Answer 2',
                              border: const OutlineInputBorder(),
                              suffixIcon: Radio<int>(
                                value: 2,
                                groupValue: q.correctAnswer,
                                onChanged: isSaving
                                    ? null
                                    : (val) {
                                        setState(() => q.correctAnswer = val!);
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: q.answer3Controller,
                            enabled: !isSaving,
                            decoration: InputDecoration(
                              labelText: 'Answer 3',
                              border: const OutlineInputBorder(),
                              suffixIcon: Radio<int>(
                                value: 3,
                                groupValue: q.correctAnswer,
                                onChanged: isSaving
                                    ? null
                                    : (val) {
                                        setState(() => q.correctAnswer = val!);
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Correct answer: ${q.correctAnswer == 1 ? "Answer 1" : q.correctAnswer == 2 ? "Answer 2" : "Answer 3"}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: isSaving ? null : _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Package'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionData {
  TextEditingController questionController;
  TextEditingController answer1Controller;
  TextEditingController answer2Controller;
  TextEditingController answer3Controller;
  int correctAnswer;

  _QuestionData({
    required this.questionController,
    required this.answer1Controller,
    required this.answer2Controller,
    required this.answer3Controller,
    this.correctAnswer = 1,
  });

  static _QuestionData empty() {
    return _QuestionData(
      questionController: TextEditingController(),
      answer1Controller: TextEditingController(),
      answer2Controller: TextEditingController(),
      answer3Controller: TextEditingController(),
      correctAnswer: 1,
    );
  }

  void dispose() {
    questionController.dispose();
    answer1Controller.dispose();
    answer2Controller.dispose();
    answer3Controller.dispose();
  }
}

// ==================== Question Package Preview ====================

class _QuestionPackagePreviewPage extends StatefulWidget {
  final String packageName;
  final List<Map<String, dynamic>> questions;

  const _QuestionPackagePreviewPage({
    required this.packageName,
    required this.questions,
  });

  @override
  State<_QuestionPackagePreviewPage> createState() =>
      _QuestionPackagePreviewPageState();
}

class _QuestionPackagePreviewPageState
    extends State<_QuestionPackagePreviewPage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  bool _finished = false;

  Map<String, dynamic> get _question => widget.questions[_currentQuestion];

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    final correctAnswer =
        _question['correctAnswer'] is int ? _question['correctAnswer'] as int : 1;
    setState(() {
      _answered = true;
      if (_selectedAnswer == correctAnswer) _correctCount++;
    });
  }

  void _nextQuestion() {
    if (!_answered) return;
    if (_currentQuestion + 1 >= widget.questions.length) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _restart() {
    setState(() {
      _currentQuestion = 0;
      _selectedAnswer = null;
      _answered = false;
      _correctCount = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return Scaffold(
        appBar: AppBar(title: Text('Preview: ${widget.packageName}')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _correctCount == widget.questions.length
                    ? Icons.celebration
                    : Icons.info_outline,
                size: 64,
                color: _correctCount == widget.questions.length
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                'Results: $_correctCount / ${widget.questions.length} correct',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _restart,
                    icon: const Icon(Icons.replay),
                    label: const Text('Try Again'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to List'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final questionText = (_question['questionText'] ?? '').toString();
    final answer1 = (_question['answer1'] ?? '').toString();
    final answer2 = (_question['answer2'] ?? '').toString();
    final answer3 = (_question['answer3'] ?? '').toString();
    final correctAnswer =
        _question['correctAnswer'] is int ? _question['correctAnswer'] as int : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Preview: ${widget.packageName}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / widget.questions.length,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentQuestion + 1} of ${widget.questions.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      questionText,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnswerOption(1, answer1, correctAnswer),
                const SizedBox(height: 8),
                _buildAnswerOption(2, answer2, correctAnswer),
                const SizedBox(height: 8),
                _buildAnswerOption(3, answer3, correctAnswer),
                const SizedBox(height: 24),
                if (!_answered)
                  ElevatedButton(
                    onPressed: _selectedAnswer != null ? _submitAnswer : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit Answer',
                        style: TextStyle(fontSize: 16)),
                  )
                else
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _selectedAnswer == correctAnswer
                          ? Colors.green
                          : Colors.red,
                    ),
                    child: Text(
                      _selectedAnswer == correctAnswer
                          ? (_currentQuestion + 1 >= widget.questions.length
                              ? 'See Results'
                              : 'Next Question')
                          : (_currentQuestion + 1 >= widget.questions.length
                              ? 'See Results'
                              : 'Next Question'),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
      int answerNum, String answerText, int correctAnswer) {
    final isSelected = _selectedAnswer == answerNum;
    final isCorrect = answerNum == correctAnswer;

    Color? backgroundColor;
    Color? borderColor;
    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue;
    }

    return GestureDetector(
      onTap: _answered
          ? null
          : () {
              setState(() => _selectedAnswer = answerNum);
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (borderColor ?? Colors.blue)
                    : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  '$answerNum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(answerText, style: const TextStyle(fontSize: 16)),
            ),
          ],
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
  final List<Map<String, dynamic>>? questions;

  const EventPreviewWelcome({
    super.key,
    required this.title,
    required this.subtitle,
    required this.boardName,
    required this.boxes,
    required this.games,
    this.questions,
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
                        questions: questions,
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
  final List<Map<String, dynamic>>? questions;

  const EventPreviewBingoBoard({
    super.key,
    required this.boardName,
    required this.boxes,
    required this.games,
    this.questions,
  });

  @override
  State<EventPreviewBingoBoard> createState() => _EventPreviewBingoBoardState();
}

class _EventPreviewBingoBoardState extends State<EventPreviewBingoBoard> {
  late List<bool> checkedBoxes;
  int checkedCount = 0;
  final _random = Random();

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
    _showSpecificMiniGame(game);
  }

  void _showSpecificMiniGame(GameConfig game) {
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

  void _showTriviaChallenge() {
    final allQuestions = List<Map<String, dynamic>>.from(widget.questions!);
    allQuestions.shuffle(_random);
    final selectedQuestions = allQuestions.take(3).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PreviewTriviaChallengePage(
          questions: selectedQuestions,
          onWin: () {
            Navigator.pop(context);
            _showMinigameWinScreen();
          },
          onLose: () {
            Navigator.pop(context);
          },
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

    // Every 3 boxes, trigger a random challenge (trivia counts as one option alongside minigames)
    if (checkedCount % 3 == 0) {
      final hasQuestions = widget.questions != null && widget.questions!.length >= 3;
      final hasGames = widget.games.isNotEmpty;

      if (hasQuestions || hasGames) {
        // Build a pool of options: each minigame is one entry, trivia is one entry
        final List<String> options = [];
        if (hasQuestions) options.add('trivia');
        for (final game in widget.games) {
          options.add('game:${game.name}');
        }
        options.shuffle(_random);
        final picked = options.first;

        if (picked == 'trivia') {
          _showTriviaChallenge();
        } else {
          final gameName = picked.substring(5); // remove 'game:' prefix
          final game = widget.games.firstWhere((g) => g.name == gameName);
          _showSpecificMiniGame(game);
        }
      }
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Preview mode — tap boxes to simulate guest play',
                          style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Games: ${widget.games.length} | '
                      'Questions: ${widget.questions != null ? "${widget.questions!.length}" : "none (no package assigned)"} | '
                      'Challenge every 3 taps',
                      style: TextStyle(fontSize: 11, color: Colors.orange.shade600),
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

// --- Preview Trivia Challenge Page (admin preview) ---
class _PreviewTriviaChallengePage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback onWin;
  final VoidCallback onLose;

  const _PreviewTriviaChallengePage({
    required this.questions,
    required this.onWin,
    required this.onLose,
  });

  @override
  State<_PreviewTriviaChallengePage> createState() =>
      _PreviewTriviaChallengePageState();
}

class _PreviewTriviaChallengePageState
    extends State<_PreviewTriviaChallengePage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;

  Map<String, dynamic> get _question => widget.questions[_currentQuestion];

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    setState(() {
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (!_answered) return;

    final correctAnswer =
        _question['correctAnswer'] is int ? _question['correctAnswer'] as int : 1;
    final wasCorrect = _selectedAnswer == correctAnswer;

    if (!wasCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wrong answer! No free pick this time.'),
          backgroundColor: Colors.red,
        ),
      );
      widget.onLose();
      return;
    }

    if (_currentQuestion + 1 >= widget.questions.length) {
      widget.onWin();
      return;
    }

    setState(() {
      _currentQuestion++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionText = (_question['questionText'] ?? '').toString();
    final answer1 = (_question['answer1'] ?? '').toString();
    final answer2 = (_question['answer2'] ?? '').toString();
    final answer3 = (_question['answer3'] ?? '').toString();
    final correctAnswer =
        _question['correctAnswer'] is int ? _question['correctAnswer'] as int : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Trivia Preview - Question ${_currentQuestion + 1}/${widget.questions.length}'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / widget.questions.length,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      questionText,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnswerOption(1, answer1, correctAnswer),
                const SizedBox(height: 8),
                _buildAnswerOption(2, answer2, correctAnswer),
                const SizedBox(height: 8),
                _buildAnswerOption(3, answer3, correctAnswer),
                const SizedBox(height: 24),
                if (!_answered)
                  ElevatedButton(
                    onPressed: _selectedAnswer != null ? _submitAnswer : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit Answer',
                        style: TextStyle(fontSize: 16)),
                  )
                else
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _selectedAnswer == correctAnswer
                          ? Colors.green
                          : Colors.red,
                    ),
                    child: Text(
                      _selectedAnswer == correctAnswer
                          ? (_currentQuestion + 1 >= widget.questions.length
                              ? 'Finish!'
                              : 'Next Question')
                          : 'Back to Board',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(
      int answerNum, String answerText, int correctAnswer) {
    final isSelected = _selectedAnswer == answerNum;
    final isCorrect = answerNum == correctAnswer;

    Color? backgroundColor;
    Color? borderColor;
    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue;
    }

    return GestureDetector(
      onTap: _answered
          ? null
          : () {
              setState(() => _selectedAnswer = answerNum);
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (borderColor ?? Colors.blue)
                    : Colors.grey.shade200,
              ),
              child: Center(
                child: Text(
                  '$answerNum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                answerText,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            if (_answered && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (_answered && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
