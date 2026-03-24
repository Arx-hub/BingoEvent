import 'package:flutter/material.dart';
import 'minigames/games_registry.dart';
import 'minigames/game_selection_page.dart';
import 'services/api_service.dart';

void main() {
  runApp(const GuestApp());
}

class GuestApp extends StatelessWidget {
  const GuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bingo Guest App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Bingo Game!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BingoBoardPage(),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class BingoWinPage extends StatelessWidget {
  const BingoWinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bingo!'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'You Completed Bingo!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thank You'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Thank you for your feedback!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameSelectionPage(
                      onGameComplete: null,
                    ),
                  ),
                );
              },
              child: const Text('Play Mini Games'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int? _selectedFeedback;
  final List<String> _feedbackEmojis = ['😞', '😕', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'We value your feedback!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFeedback = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: _selectedFeedback == index
                          ? Colors.blue.withValues(alpha: 0.3)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedFeedback == index
                            ? Colors.blue
                            : Colors.grey,
                        width: _selectedFeedback == index ? 2.0 : 1.0,
                      ),
                    ),
                    child: Text(
                      _feedbackEmojis[index],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedFeedback != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThankYouPage(),
                        ),
                      );
                    }
                  : null,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}

class MinigameWinPage extends StatelessWidget {
  final VoidCallback onContinue;

  const MinigameWinPage({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congratulations!'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'You Won!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'You get a free pick on the bingo board',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class BingoBoardPage extends StatefulWidget {
  const BingoBoardPage({super.key});

  @override
  State<BingoBoardPage> createState() => _BingoBoardPageState();
}

class _BingoBoardPageState extends State<BingoBoardPage> {
  final List<List<String>> _board = List.generate(5, (i) => List.generate(5, (j) => 'Box ${i + 1},${j + 1}'));
  final List<List<bool>> _checkedBoxes = List.generate(5, (_) => List.generate(5, (_) => false));
  int _checkedCount = 0;
  int? _boardId; // Track the saved board ID
  bool _isSaving = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _saveBoardToDatabase();
  }

  /// Saves the current board to the database
  Future<void> _saveBoardToDatabase() async {
    if (_isSaving) return; // Prevent multiple simultaneous saves

    setState(() {
      _isSaving = true;
    });

    try {
      // Flatten the 2D board into a 1D list
      final List<String> flatBoard = [];
      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          flatBoard.add(_board[i][j]);
        }
      }

      // Create the board via API
      final response = await ApiService.createBingoBoard(
        'Bingo Board ${DateTime.now().toLocal()}',
        flatBoard,
      );

      setState(() {
        _boardId = response['boardId'] as int?;
        _isSaving = false;
      });

      print('Board saved with ID: $_boardId');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Board saved! (ID: $_boardId)'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      print('Error saving board: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving board: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkWinCondition() {
    // Check rows
    for (var row in _checkedBoxes) {
      if (row.every((box) => box)) {
        _redirectToBingoWin();
        return;
      }
    }

    // Check columns
    for (int col = 0; col < 5; col++) {
      if (_checkedBoxes.every((row) => row[col])) {
        _redirectToBingoWin();
        return;
      }
    }

    // Check diagonals
    if (List.generate(5, (index) => _checkedBoxes[index][index]).every((box) => box) ||
        List.generate(5, (index) => _checkedBoxes[index][4 - index]).every((box) => box)) {
      _redirectToBingoWin();
    }
  }

  void _redirectToBingoWin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BingoWinPage(),
      ),
    );
  }

  void _showMiniGame() {
    final randomGame = GamesRegistry.getRandomGame();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => randomGame.gamePageBuilder(
          context,
          () {
            // On win: Pop game and show minigame win screen
            Navigator.pop(context);
            _showMinigameWinScreen();
          },
          () {
            // On skip: Pop back to bingo board
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
        builder: (context) => MinigameWinPage(
          onContinue: () {
            Navigator.pop(context);
            _selectBoxToMark();
          },
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
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 25,
            itemBuilder: (context, index) {
              final row = index ~/ 5;
              final col = index % 5;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _board[row][col] = 'Won game';
                    _checkedBoxes[row][col] = true;
                  });
                  Navigator.pop(context);
                  _checkWinCondition();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _checkedBoxes[row][col] ? Colors.green : Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      _board[row][col],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bingo Board'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: _boardId != null
                  ? Text(
                      'Board ID: $_boardId',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : _isSaving
                      ? const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text(
                          'Not saved',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Save button at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveBoardToDatabase,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Board'),
            ),
          ),
          // Bingo board grid
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 5x5 bingo board
                    crossAxisSpacing: 6.0,
                    mainAxisSpacing: 6.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 25, // Total number of boxes
                  itemBuilder: (context, index) {
                    final row = index ~/ 5;
                    final col = index % 5;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_checkedBoxes[row][col]) {
                            _checkedBoxes[row][col] = true;
                            _checkedCount++;
                            if (_checkedCount % 3 == 0) {
                              _showMiniGame();
                            }
                            _checkWinCondition();
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _checkedBoxes[row][col] ? Colors.green : Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Center(
                          child: Text(
                            _board[row][col],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


