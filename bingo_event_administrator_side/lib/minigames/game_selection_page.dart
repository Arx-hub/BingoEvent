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
            // On win: Pop game page and show win screen
            Navigator.pop(context);
            _showGameWinScreen(context, game.name);
          },
          () {
            // On skip: Pop back to game selection
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showGameWinScreen(BuildContext context, String gameName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameWinPage(
          gameName: gameName,
          onContinue: () {
            Navigator.pop(context);
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: GamesRegistry.availableGames.length,
          itemBuilder: (context, index) {
            final game = GamesRegistry.availableGames[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                title: Text(game.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(game.description, style: const TextStyle(fontSize: 12)),
                trailing: ElevatedButton(
                  onPressed: () => _startGame(context, game),
                  child: const Text('Play'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GameWinPage extends StatelessWidget {
  final String gameName;
  final VoidCallback onContinue;

  const GameWinPage({
    super.key,
    required this.gameName,
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
            const SizedBox(height: 12),
            Text(
              gameName,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
