# Minigames System

This folder contains the minigames that appear during the bingo game on the guest side.

## Structure

- **memory_game/**: The memory card matching game
- **games_registry.dart**: Central registry for all available games
- **game_selection_page.dart**: Page that displays available games when players finish feedback

## How to Add a New Game

1. Create a new folder under `minigames/` (e.g., `your_game_name/`)
2. Create your game widget file (e.g., `your_game_widget.dart`)
3. Your widget should:
   - Accept `onWin` and `onSkip` callbacks
   - Call `onWin()` when the player wins
   - Call `onSkip()` when the player clicks skip
4. Register your game in `games_registry.dart`:

```dart
GameConfig(
  id: 'your_game_id',
  name: 'Your Game Name',
  description: 'Brief description',
  gamePageBuilder: (context, onWin, onSkip) => YourGameWidget(
    onWin: onWin,
    onSkip: onSkip,
  ),
),
```

## Memory Game

The memory game is a card-matching game where players flip cards to find matching pairs.

### Customizing Card Images

The MemoryGamePage accepts a `cardImages` parameter with a list of strings. You can:

**Option 1: Use Emojis (Default)**
```dart
const cardImages = [
  '🍎', '🍌', '🍊', '🍋', '🍉',
  '🍒', '🍑', '🍐', '🥝', '🍍',
  // ... repeated for pairs
]
```

**Option 2: Use Image Paths**
```dart
const cardImages = [
  'assets/images/card1.png',
  'assets/images/card2.png',
  // ... and so on
]
```

Then update the MemoryCard widget to handle image paths:
```dart
if (_isFlipped || _isMatched) {
  if (cardContent.startsWith('assets/') || cardContent.startsWith('/')) {
    child: Image.asset(cardContent); // or Image.file()
  } else {
    child: Text(cardContent); // emoji or text
  }
}
```

## Game Flow

1. Player checks 3 bingo boxes
2. A random game is selected and displayed
3. If player wins: Box selection dialog appears
4. If player skips: Returns to bingo board
5. After feedback submissions: Can choose from available games to play for fun

## Notes

- Games are randomly selected from the registry when triggered during gameplay
- The feedback functionality is separate and untouched
- Each game runs independently and can be tested in isolation
