import 'package:flutter/material.dart';
import 'memory_game/memory_game.dart';

class GameConfig {
  final String id;
  final String name;
  final String description;
  final Widget Function(
    BuildContext context,
    VoidCallback? onWin,
    VoidCallback? onSkip,
  ) gamePageBuilder;

  GameConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.gamePageBuilder,
  });
}

class GamesRegistry {
  static final List<GameConfig> availableGames = [
    GameConfig(
      id: 'memory_game',
      name: 'Memory Game',
      description: 'Match pairs of cards by memory',
      gamePageBuilder: (context, onWin, onSkip) => MemoryGamePage(
        onWin: onWin,
        onSkip: onSkip,
      ),
    ),
    // Add more games here as they are created
  ];

  static GameConfig getGameById(String id) {
    return availableGames.firstWhere(
      (game) => game.id == id,
      orElse: () => availableGames[0],
    );
  }

  static GameConfig getRandomGame() {
    availableGames.shuffle();
    return availableGames[0];
  }
}
