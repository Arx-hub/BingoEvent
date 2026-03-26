import 'package:flutter/material.dart';
import 'dart:math';
import 'minigames/games_registry.dart';
import 'minigames/game_selection_page.dart';

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
  final List<Map<String, dynamic>>? questions;

  const BingoBoardPage({super.key, this.questions});

  @override
  State<BingoBoardPage> createState() => _BingoBoardPageState();
}

class _BingoBoardPageState extends State<BingoBoardPage> {
  final List<List<String>> _board = List.generate(5, (i) => List.generate(5, (j) => 'Box ${i + 1},${j + 1}'));
  final List<List<bool>> _checkedBoxes = List.generate(5, (_) => List.generate(5, (_) => false));
  int _checkedCount = 0;
  final _random = Random();

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

  void _onThreeBoxesChecked() {
    // Trivia is treated as one minigame option in the pool
    final hasQuestions = widget.questions != null && widget.questions!.length >= 3;
    final games = GamesRegistry.availableGames;
    final hasGames = games.isNotEmpty;

    if (hasQuestions || hasGames) {
      // Build a pool: trivia is one entry, each minigame is one entry
      final List<String> options = [];
      if (hasQuestions) options.add('trivia');
      for (final game in games) {
        options.add('game:${game.name}');
      }
      options.shuffle(_random);
      final picked = options.first;

      if (picked == 'trivia') {
        _showTriviaChallenge();
      } else {
        final gameName = picked.substring(5); // remove 'game:' prefix
        final game = games.firstWhere((g) => g.name == gameName);
        _showSpecificMiniGame(game);
      }
    }
  }

  void _showTriviaChallenge() {
    // Pick 3 random questions
    final allQuestions = List<Map<String, dynamic>>.from(widget.questions!);
    allQuestions.shuffle(_random);
    final selectedQuestions = allQuestions.take(3).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TriviaChallengePage(
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

  void _showMiniGame() {
    final randomGame = GamesRegistry.getRandomGame();
    _showSpecificMiniGame(randomGame);
  }

  void _showSpecificMiniGame(GameConfig game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => game.gamePageBuilder(
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
      ),
      body: Center(
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
                        _onThreeBoxesChecked();
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
    );
  }
}

// ==================== Trivia Challenge Page ====================

class TriviaChallengePage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback onWin;
  final VoidCallback onLose;

  const TriviaChallengePage({
    super.key,
    required this.questions,
    required this.onWin,
    required this.onLose,
  });

  @override
  State<TriviaChallengePage> createState() => _TriviaChallengePageState();
}

class _TriviaChallengePageState extends State<TriviaChallengePage> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;

  Map<String, dynamic> get _question => widget.questions[_currentQuestion];

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final correctAnswer = _question['correctAnswer'] is int
        ? _question['correctAnswer'] as int
        : 1;

    setState(() {
      _answered = true;
      if (_selectedAnswer == correctAnswer) {
        _correctCount++;
      }
    });
  }

  void _nextQuestion() {
    if (!_answered) return;

    final correctAnswer = _question['correctAnswer'] is int
        ? _question['correctAnswer'] as int
        : 1;
    final wasCorrect = _selectedAnswer == correctAnswer;

    if (!wasCorrect) {
      // Wrong answer - fail immediately
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
      // All questions answered correctly
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
    final correctAnswer = _question['correctAnswer'] is int
        ? _question['correctAnswer'] as int
        : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trivia - Question ${_currentQuestion + 1}/${widget.questions.length}'),
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
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / widget.questions.length,
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(height: 24),
                // Question
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      questionText,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Answers
                ...[ 
                  _buildAnswerOption(1, answer1, correctAnswer),
                  const SizedBox(height: 8),
                  _buildAnswerOption(2, answer2, correctAnswer),
                  const SizedBox(height: 8),
                  _buildAnswerOption(3, answer3, correctAnswer),
                ],
                const SizedBox(height: 24),
                if (!_answered)
                  ElevatedButton(
                    onPressed: _selectedAnswer != null ? _submitAnswer : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Submit Answer', style: TextStyle(fontSize: 16)),
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

  Widget _buildAnswerOption(int answerNum, String answerText, int correctAnswer) {
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

