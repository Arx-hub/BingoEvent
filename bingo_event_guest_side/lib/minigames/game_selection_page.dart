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
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: GamesRegistry.availableGames.length,
          itemBuilder: (context, index) {
            final game = GamesRegistry.availableGames[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(game.name),
                subtitle: Text(game.description),
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
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              'You Won!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              gameName,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
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
