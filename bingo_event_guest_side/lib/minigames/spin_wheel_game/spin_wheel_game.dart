import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SpinWheelGamePage extends StatefulWidget {
  final VoidCallback? onWin;
  final VoidCallback? onSkip;

  const SpinWheelGamePage({
    super.key,
    this.onWin,
    this.onSkip,
  });

  @override
  State<SpinWheelGamePage> createState() => _SpinWheelGamePageState();
}

class _SpinWheelGamePageState extends State<SpinWheelGamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  
  String? _playerGuess; // "red" or "blue"
  String? _wheelResult; // "red" or "blue"
  bool _hasSpun = false;
  bool _showResult = false;
  bool _isOverlayVisible = false;
  
  final List<String> _colors = ['red', 'blue'];
  final List<Color> _colorValues = [Colors.red, Colors.blue];
  
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    // Initialize with default animation
    _spinAnimation = Tween<double>(begin: 0, end: 0).animate(_spinController);
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _onGuessColor(String color) {
    setState(() {
      _playerGuess = color;
    });
  }

  void _spinWheel() {
    if (_playerGuess == null || _hasSpun) return;

    // Generate random result (0 or 1, representing red or blue)
    int resultIndex = _random.nextInt(2);
    _wheelResult = _colors[resultIndex];

    // Create animation
    // Note: resultIndex 0 (red) needs 180° rotation to move red to bottom
    // resultIndex 1 (blue) needs 0° rotation to keep blue at bottom
    _spinAnimation = Tween<double>(
      begin: 0,
      end: 15 * pi + ((1 - resultIndex) * pi), // Spin ~4 full rotations + final position
    ).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    setState(() {
      _hasSpun = true;
    });

    _spinController.forward(from: 0).then((_) {
      // Show result after spin completes
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showResult = true;
            _isOverlayVisible = true;
          });
        }
      });
    });
  }

  void _continueAfterResult() {
    bool won = _playerGuess == _wheelResult;
    
    if (won) {
      widget.onWin?.call();
    } else {
      widget.onSkip?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin the Wheel'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isOverlayVisible ? null : widget.onSkip,
        ),
      ),
      body: Stack(
        children: [
          // Main game content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Title
                  const Text(
                    'Make a Guess!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Which color will the arrow land on?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Color selection buttons
                  if (!_hasSpun)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildColorButton('Red', Colors.red, 0),
                        const SizedBox(width: 20),
                        _buildColorButton('Blue', Colors.blue, 1),
                      ],
                    ),

                  const SizedBox(height: 40),

                  // Wheel display
                  Center(
                    child: Column(
                      children: [
                        // Arrow pointing down
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 40,
                          color: Colors.black87,
                        ),
                        
                        // Wheel
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: AnimatedBuilder(
                            animation: _spinAnimation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _spinAnimation.value,
                                child: CustomPaint(
                                  painter: WheelPainter(),
                                  size: const Size(280, 280),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Display of player's guess
                  if (_playerGuess != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'You guessed: ${_playerGuess![0].toUpperCase()}${_playerGuess!.substring(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Spin button
                  ElevatedButton.icon(
                    onPressed: _hasSpun ? null : _spinWheel,
                    icon: const Icon(Icons.casino, size: 28),
                    label: const Text(
                      'SPIN THE WHEEL',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      backgroundColor:
                          _hasSpun ? Colors.grey : Colors.deepPurple,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Result overlay
          if (_showResult)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Result emoji
                        Text(
                          _playerGuess == _wheelResult ? '🎉' : '😢',
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 20),

                        // Result text
                        Text(
                          _playerGuess == _wheelResult ? 'You Won!' : 'You Lost!',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Details
                        Text(
                          'The wheel landed on ${_wheelResult![0].toUpperCase()}${_wheelResult!.substring(1)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Continue button
                        ElevatedButton(
                          onPressed: _continueAfterResult,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 16,
                            ),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorButton(String label, Color color, int index) {
    bool isSelected = _playerGuess == _colors[index];
    
    return GestureDetector(
      onTap: _hasSpun ? null : () => _onGuessColor(_colors[index]),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.black87, width: 4)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw wheel segments
    const colors = [Colors.red, Colors.blue];
    
    for (int i = 0; i < 2; i++) {
      paint.color = colors[i];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (i * pi),
        pi,
        true,
        paint,
      );
    }

    // Draw border circle
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(center, radius, borderPaint);

    // Draw center circle
    final centerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 15, centerPaint);
    
    final centerBorderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 15, centerBorderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
