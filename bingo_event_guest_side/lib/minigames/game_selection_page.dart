import 'package:flutter/material.dart';
import 'games_registry.dart';

class GameSelectionPage extends StatelessWidget {
  final VoidCallback? onGameComplete;

  const GameSelectionPage({super.key, this.onGameComplete});

  void _startGame(BuildContext context, GameConfig game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => game.gamePageBuilder(
          context,
          () {
            // On win
            Navigator.pop(context);
            _showGameResultScreen(context, game, true);
          },
          () {
            // On lose
            Navigator.pop(context);
            _showGameResultScreen(context, game, false);
          },
          () {
            // On skip
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showGameResultScreen(BuildContext context, GameConfig game, bool isWin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameResultPage(
          game: game,
          isWin: isWin,
          onTryAgain: () {
            Navigator.pop(context); // Pop result page
            _startGame(context, game); // Restart game
          },
          onGoBack: () {
            Navigator.pop(context); // Pop result page
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: GamesRegistry.availableGames.length,
              itemBuilder: (context, index) {
                final game = GamesRegistry.availableGames[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    title: Text(game.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text(game.description, style: const TextStyle(fontSize: 14)),
                    trailing: ElevatedButton(
                      onPressed: () => _startGame(context, game),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Play'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GameResultPage extends StatelessWidget {
  final GameConfig game;
  final bool isWin;
  final VoidCallback onTryAgain;
  final VoidCallback onGoBack;

  const GameResultPage({
    super.key,
    required this.game,
    required this.isWin,
    required this.onTryAgain,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isWin ? 'Congratulations!' : 'Game Over'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isWin ? '🎉' : '😢',
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                isWin ? 'You Won!' : 'You Lost!',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: onGoBack,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: onTryAgain,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Try Again'),
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
