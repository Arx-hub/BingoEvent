import 'package:flutter/material.dart';
import 'dart:math';

class MinesweeperGamePage extends StatefulWidget {
  final VoidCallback? onWin;
  final VoidCallback? onSkip;
  final int gridSize;
  final int mineCount;

  const MinesweeperGamePage({
    super.key,
    this.onWin,
    this.onSkip,
    this.gridSize = 5,
    this.mineCount = 3,
  });

  @override
  State<MinesweeperGamePage> createState() => _MinesweeperGamePageState();
}

class _MinesweeperGamePageState extends State<MinesweeperGamePage> {
  late List<List<bool>> _mines;
  late List<List<bool>> _revealed;
  late List<List<bool>> _flagged;
  late int _totalSafeSquares;
  late int _revealedSafeSquares;
  bool _gameOver = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final gridSize = widget.gridSize;
    _mines = List.generate(gridSize, (_) => List.filled(gridSize, false));
    _revealed = List.generate(gridSize, (_) => List.filled(gridSize, false));
    _flagged = List.generate(gridSize, (_) => List.filled(gridSize, false));

    // Place mines randomly
    final random = Random();
    int minesPlaced = 0;
    while (minesPlaced < widget.mineCount) {
      final row = random.nextInt(gridSize);
      final col = random.nextInt(gridSize);
      if (!_mines[row][col]) {
        _mines[row][col] = true;
        minesPlaced++;
      }
    }

    _totalSafeSquares = (gridSize * gridSize) - widget.mineCount;
    _revealedSafeSquares = 0;
    _gameOver = false;
    _won = false;
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    final gridSize = widget.gridSize;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        final newRow = row + i;
        final newCol = col + j;
        if (newRow >= 0 &&
            newRow < gridSize &&
            newCol >= 0 &&
            newCol < gridSize &&
            _mines[newRow][newCol]) {
          count++;
        }
      }
    }
    return count;
  }

  void _revealSquare(int row, int col) {
    if (_gameOver || _won || _revealed[row][col] || _flagged[row][col]) {
      return;
    }

    setState(() {
      if (_mines[row][col]) {
        // Hit a mine - game over
        _gameOver = true;
        _revealed[row][col] = true;
      } else {
        // Safe square
        _revealed[row][col] = true;
        _revealedSafeSquares++;

        // Check if won
        if (_revealedSafeSquares == _totalSafeSquares) {
          _won = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (widget.onWin != null) {
              widget.onWin!();
            }
          });
        }

        // Recursively reveal adjacent squares if no adjacent mines
        if (_countAdjacentMines(row, col) == 0) {
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              final newRow = row + i;
              final newCol = col + j;
              if (newRow >= 0 &&
                  newRow < widget.gridSize &&
                  newCol >= 0 &&
                  newCol < widget.gridSize &&
                  !_revealed[newRow][newCol]) {
                _revealSquare(newRow, newCol);
              }
            }
          }
        }
      }
    });

    // Show game over dialog if player hit a mine
    if (_gameOver) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _showGameOverDialog();
      });
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('You Lost! 💣'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              'You hit a bomb!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'You get no free pick on the bingo board.',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onSkip?.call(); // Go back to bingo board
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _toggleFlag(int row, int col) {
    if (_gameOver || _won || _revealed[row][col]) {
      return;
    }

    setState(() {
      _flagged[row][col] = !_flagged[row][col];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  'Safe squares: $_revealedSafeSquares / $_totalSafeSquares',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 6),
                if (_won)
                  const Text(
                    '🎉 YOU WON!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                ),
                itemCount: widget.gridSize * widget.gridSize,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final row = index ~/ widget.gridSize;
                  final col = index % widget.gridSize;
                  return MinesweeperSquare(
                    isMine: _mines[row][col],
                    isRevealed: _revealed[row][col],
                    isFlagged: _flagged[row][col],
                    adjacentMines: _countAdjacentMines(row, col),
                    onTap: () => _revealSquare(row, col),
                    onLongPress: () => _toggleFlag(row, col),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _gameOver || _won
                      ? null
                      : () {
                          setState(() {
                            _initializeGame();
                          });
                        },
                  child: const Text('Restart'),
                ),
                ElevatedButton(
                  onPressed: _gameOver || _won ? null : widget.onSkip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Skip'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MinesweeperSquare extends StatelessWidget {
  final bool isMine;
  final bool isRevealed;
  final bool isFlagged;
  final int adjacentMines;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MinesweeperSquare({
    super.key,
    required this.isMine,
    required this.isRevealed,
    required this.isFlagged,
    required this.adjacentMines,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _getSquareColor(),
          border: Border.all(
            color: Colors.grey[400] ?? Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            if (!isRevealed)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 2.0,
                offset: const Offset(1, 1),
              ),
          ],
        ),
        child: Center(
          child: _buildSquareContent(),
        ),
      ),
    );
  }

  Color _getSquareColor() {
    if (isFlagged) {
      return Colors.amber[100] ?? Colors.amber;
    }
    if (isRevealed) {
      if (isMine) {
        return Colors.red[300] ?? Colors.red;
      }
      return Colors.grey[200] ?? Colors.grey;
    }
    return Colors.grey[600] ?? Colors.grey;
  }

  Widget _buildSquareContent() {
    if (isFlagged && !isRevealed) {
      return const Text(
        '🚩',
        style: TextStyle(fontSize: 32),
      );
    }

    if (!isRevealed) {
      return const SizedBox.expand();
    }

    if (isMine) {
      return const Text(
        '💣',
        style: TextStyle(fontSize: 32),
      );
    }

    if (adjacentMines == 0) {
      return const SizedBox.expand();
    }

    return Text(
      '$adjacentMines',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }
}
