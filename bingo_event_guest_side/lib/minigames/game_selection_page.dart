import 'package:flutter/material.dart';
import 'games_registry.dart';

class GameSelectionPage extends StatelessWidget {
  final VoidCallback? onGameComplete;

  const GameSelectionPage({super.key, this.onGameComplete});

  void _startGame(BuildContext context, String gameId) {
    final game = GamesRegistry.getGameById(gameId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => game.gamePageBuilder(
          context,
          () {
            // On win: Pop game page
            Navigator.pop(context);
            // Show the box selection dialog (will be handled by parent)
            if (onGameComplete != null) {
              onGameComplete!();
            }
          },
          () {
            // On skip: Pop back to game selection
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
                  onPressed: () => _startGame(context, game.id),
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
