import 'package:flutter/material.dart';
import 'memory_game/memory_game.dart';
import 'minesweeper_game/minesweeper_game.dart';
import 'spin_wheel_game/spin_wheel_game.dart';

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
    GameConfig(
      id: 'minesweeper_game',
      name: 'Minesweeper',
      description: 'Reveal safe squares and avoid mines',
      gamePageBuilder: (context, onWin, onSkip) => MinesweeperGamePage(
        onWin: onWin,
        onSkip: onSkip,
      ),
    ),
    GameConfig(
      id: 'spin_wheel_game',
      name: 'Spin the Wheel',
      description: 'Guess which color the wheel will land on',
      gamePageBuilder: (context, onWin, onSkip) => SpinWheelGamePage(
        onWin: onWin,
        onSkip: onSkip,
      ),
    ),
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
