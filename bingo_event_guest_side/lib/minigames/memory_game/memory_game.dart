import 'package:flutter/material.dart';
import 'dart:math';

class MemoryGamePage extends StatefulWidget {
  final VoidCallback? onWin;
  final VoidCallback? onSkip;
  final List<String> cardImages;

  const MemoryGamePage({
    super.key,
    this.onWin,
    this.onSkip,
    this.cardImages = const [
      '🍎', '🍌', '🍊', '🍋', '🍉',
      '🍒', '🍑', '🍐', '🥝', '🍍',
      '🍎', '🍌', '🍊', '🍋', '🍉',
      '🍒', '🍑', '🍐', '🥝', '🍍',
    ],
  });

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  late List<String> _cards;
  late List<bool> _isFlipped;
  late List<bool> _isMatched;
  int? _firstIndex;
  int? _secondIndex;
  bool _isLocked = false;
  int _matchedPairs = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _cards = List.from(widget.cardImages);
    _isFlipped = List.filled(_cards.length, false);
    _isMatched = List.filled(_cards.length, false);
    _firstIndex = null;
    _secondIndex = null;
    _isLocked = false;
    _matchedPairs = 0;

    // Shuffle the cards
    final random = Random();
    _cards.shuffle(random);
  }

  void _onCardTapped(int index) {
    if (_isLocked || _isFlipped[index] || _isMatched[index]) {
      return;
    }

    setState(() {
      _isFlipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else if (_secondIndex == null) {
      _secondIndex = index;
      _isLocked = true;

      // Check if cards match after a short delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_cards[_firstIndex!] == _cards[_secondIndex!]) {
          // Cards match
          setState(() {
            _isMatched[_firstIndex!] = true;
            _isMatched[_secondIndex!] = true;
            _matchedPairs++;

            // Check if won
            if (_matchedPairs == _cards.length ~/ 2) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (widget.onWin != null) {
                  widget.onWin!();
                }
              });
            }

            _firstIndex = null;
            _secondIndex = null;
            _isLocked = false;
          });
        } else {
          // Cards don't match
          setState(() {
            _isFlipped[_firstIndex!] = false;
            _isFlipped[_secondIndex!] = false;
            _firstIndex = null;
            _secondIndex = null;
            _isLocked = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pairs found: $_matchedPairs / ${_cards.length ~/ 2}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTapped(index),
                    child: MemoryCard(
                      isFlipped: _isFlipped[index],
                      isMatched: _isMatched[index],
                      cardContent: _cards[index],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _initializeGame();
                    });
                  },
                  child: const Text('Restart Game'),
                ),
                ElevatedButton(
                  onPressed: widget.onSkip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Skip Game'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryCard extends StatelessWidget {
  final bool isFlipped;
  final bool isMatched;
  final String cardContent;

  const MemoryCard({
    super.key,
    required this.isFlipped,
    required this.isMatched,
    required this.cardContent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isMatched
            ? Colors.grey[300]
            : isFlipped
                ? Colors.blue
                : Colors.blue[600],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.blue[900] ?? Colors.blue,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isFlipped || isMatched
            ? Text(
                cardContent,
                style: const TextStyle(fontSize: 32),
              )
            : const Icon(
                Icons.public,
                color: Colors.white,
                size: 40,
              ),
      ),
    );
  }
}
