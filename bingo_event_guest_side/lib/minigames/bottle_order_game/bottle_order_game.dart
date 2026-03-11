import 'package:flutter/material.dart';

class BottleOrderGamePage extends StatefulWidget {
  final VoidCallback? onWin;
  final VoidCallback? onSkip;

  const BottleOrderGamePage({
    super.key,
    this.onWin,
    this.onSkip,
  });

  @override
  State<BottleOrderGamePage> createState() => _BottleOrderGamePageState();
}

// Widget to display a draggable bottle
class DraggableBottleWidget extends StatefulWidget {
  final BottleColor bottle;
  final int index;
  final bool isCorrect;
  final bool isGameEnded;
  final Function(int, int) onReorder;

  const DraggableBottleWidget({
    super.key,
    required this.bottle,
    required this.index,
    required this.isCorrect,
    required this.isGameEnded,
    required this.onReorder,
  });

  @override
  State<DraggableBottleWidget> createState() => _DraggableBottleWidgetState();
}

class _DraggableBottleWidgetState extends State<DraggableBottleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void animateToPosition(Offset target) {
    _offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: target).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Draggable<int>(
        data: widget.index,
        feedback: Transform.scale(
          scale: 1.1,
          child: Opacity(
            opacity: 0.8,
            child: _buildBottle(widget.bottle, size: 60),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.4,
          child: _buildBottle(widget.bottle, size: 60),
        ),
        onDragEnd: (details) {
          // Animate back if not dropped on target
          animateToPosition(Offset.zero);
        },
        child: DragTarget<int>(
          builder: (context, candidateData, rejectedData) {
            return Stack(
              alignment: Alignment.topRight,
              children: [
                _buildBottle(
                  widget.bottle,
                  size: 60,
                ),
                // Green tick for correct position
                if (widget.isCorrect)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            );
          },
          onAccept: (draggedIndex) {
            widget.onReorder(draggedIndex, widget.index);
          },
        ),
      ),
    );
  }

  Widget _buildBottle(BottleColor bottle, {double size = 60}) {
    return Column(
      children: [
        Container(
          width: size,
          height: size * 1.2,
          decoration: BoxDecoration(
            color: bottle.color,
            borderRadius: BorderRadius.circular(size * 0.15),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: bottle.color.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: size * 0.6,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(size * 0.08),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BottleColor {
  final int id;
  final Color color;
  final String name;

  BottleColor({required this.id, required this.color, required this.name});
}

class _BottleOrderGamePageState extends State<BottleOrderGamePage> {
  late List<BottleColor> _hiddenBottles;
  late List<BottleColor> _userBottles;
  late List<bool> _correctPositions;
  late List<GlobalKey<_DraggableBottleWidgetState>> _bottleKeys;
  
  int _attemptsLeft = 3;
  bool _barrierRemoved = false;
  bool _gameEnded = false;
  bool _won = false;
  
  final List<BottleColor> _availableColors = [
    BottleColor(id: 1, color: Colors.red, name: 'Red'),
    BottleColor(id: 2, color: Colors.blue, name: 'Blue'),
    BottleColor(id: 3, color: Colors.yellow, name: 'Yellow'),
    BottleColor(id: 4, color: Colors.green, name: 'Green'),
    BottleColor(id: 5, color: Colors.purple, name: 'Purple'),
  ];

  @override
  void initState() {
    super.initState();
    _bottleKeys = List.generate(5, (_) => GlobalKey<_DraggableBottleWidgetState>());
    _initializeGame();
  }

  void _initializeGame() {
    // Create hidden bottle order (shuffled)
    _hiddenBottles = List.from(_availableColors);
    _hiddenBottles.shuffle();
    
    // Create user bottles (shuffled differently)
    _userBottles = List.from(_availableColors);
    _userBottles.shuffle();
    
    _correctPositions = List.filled(5, false);
    _attemptsLeft = 3;
    _barrierRemoved = false;
    _gameEnded = false;
    _won = false;
  }

  void _updateCorrectPositions() {
    for (int i = 0; i < 5; i++) {
      _correctPositions[i] = _userBottles[i].id == _hiddenBottles[i].id;
    }
  }

  void _onSubmitAttempt() {
    setState(() {
      _updateCorrectPositions();
      _attemptsLeft--;
      
      // Check if all bottles are in correct positions
      bool allCorrect = _correctPositions.every((correct) => correct);
      
      if (allCorrect) {
        _barrierRemoved = true;
        _gameEnded = true;
        _won = true;
        // Don't auto-call onWin - let player press Continue button!
      } else if (_attemptsLeft <= 0) {
        // Game over, show barrier removal
        _barrierRemoved = true;
        _gameEnded = true;
        // Don't auto-call onSkip - let player press Continue button!
      }
    });
  }

  void _swapBottles(int index1, int index2) {
    if (_gameEnded) return;
    
    setState(() {
      // Clear checkmarks on any bottles being moved (they're no longer in original position)
      _correctPositions[index1] = false;
      _correctPositions[index2] = false;
      
      final temp = _userBottles[index1];
      _userBottles[index1] = _userBottles[index2];
      _userBottles[index2] = temp;
      // Don't update correct positions here - only on submit!
    });
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }

  Widget _buildBottleSimple(BottleColor bottle, {double size = 60}) {
    return Column(
      children: [
        Container(
          width: size,
          height: size * 1.2,
          decoration: BoxDecoration(
            color: bottle.color,
            borderRadius: BorderRadius.circular(size * 0.15),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: bottle.color.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: size * 0.6,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(size * 0.08),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottle Order Game'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Attempts Counter
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  'Attempts Left: $_attemptsLeft',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Match the hidden bottles to their correct positions',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Hidden Bottles Section (Example)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hidden Bottles:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Hidden Bottles - Only show revealed bottles after game ends
                if (_barrierRemoved)
                  Container(
                    constraints: const BoxConstraints(minHeight: 120),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBottleSimple(
                                  _hiddenBottles[index],
                                  size: 50,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '#${index + 1}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  )
                else
                  // Barrier - Completely solid cover while playing
                  Container(
                    constraints: const BoxConstraints(minHeight: 150),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.grey,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Hidden',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Your Bottles Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Bottles (drag to reorder):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            DraggableBottleWidget(
                              key: _bottleKeys[index],
                              bottle: _userBottles[index],
                              index: index,
                              isCorrect: _correctPositions[index],
                              isGameEnded: _gameEnded,
                              onReorder: _swapBottles,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pos ${index + 1}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Game Status Message
          if (_barrierRemoved)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (_won)
                    const Text(
                      '🎉 YOU WON! You matched all bottles correctly!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else
                    const Text(
                      '❌ Game Over! The bottles did not match.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _won ? widget.onWin : widget.onSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _won ? Colors.green : Colors.orange,
                    ),
                    child: Text(_won ? 'Claim Prize!' : 'Continue'),
                  ),
                ],
              ),
            ),
          
          // Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (!_gameEnded)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: [
                      ElevatedButton(
                        onPressed: _restartGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Restart', style: TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        onPressed: _onSubmitAttempt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Submit', style: TextStyle(fontSize: 12)),
                      ),
                      ElevatedButton(
                        onPressed: widget.onSkip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('Skip', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  )
                else if (!_barrierRemoved)
                  // Show Skip button while game ended but barrier not removed yet
                  ElevatedButton(
                    onPressed: widget.onSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Skip Reveal'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
