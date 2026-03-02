import 'package:flutter/material.dart';

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
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MiniGamePage(
                      onWin: null,
                      onSkip: null,
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

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Feedback',
                hintText: 'Let us know your thoughts...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThankYouPage(),
                  ),
                );
              },
              child: const Text('Submit Feedback'),
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

  void _checkWinCondition() {
    // Check rows
    for (var row in _checkedBoxes) {
      if (row.every((box) => box)) {
        _redirectToFeedback();
        return;
      }
    }

    // Check columns
    for (int col = 0; col < 5; col++) {
      if (_checkedBoxes.every((row) => row[col])) {
        _redirectToFeedback();
        return;
      }
    }

    // Check diagonals
    if (List.generate(5, (index) => _checkedBoxes[index][index]).every((box) => box) ||
        List.generate(5, (index) => _checkedBoxes[index][4 - index]).every((box) => box)) {
      _redirectToFeedback();
    }
  }

  void _redirectToFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FeedbackPage(),
      ),
    );
  }

  void _showMiniGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiniGamePage(
          onWin: () {
            Navigator.pop(context);
            _selectBoxToMark();
          },
          onSkip: () {
            Navigator.pop(context);
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 5x5 bingo board
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
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
    );
  }
}

class MiniGamePage extends StatelessWidget {
  final VoidCallback? onWin;
  final VoidCallback? onSkip;

  const MiniGamePage({super.key, this.onWin, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onWin,
              child: const Text('Win Game'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSkip,
              child: const Text('Skip Game'),
            ),
          ],
        ),
      ),
    );
  }
}
