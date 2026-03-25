# Minigames System Architecture

## Game Flow Diagram

```
DURING GAMEPLAY:
================

Bingo Board
    ↓ [Check 3 boxes]
    ↓
Trigger Random Game
    ↓ [Select game from registry]
    ↓
Memory Game (or future games)
    ├─ [Player Wins] → Pop Game → Select Box Dialog
    │                              ↓
    │                         Mark Box & Continue
    │
    └─ [Player Skips] → Pop Back to Bingo Board


AFTER WINNING BINGO:
===================

Bingo Board (Complete)
    ↓
Feedback Page → Submit Feedback
    ↓
Thank You Page
    ↓ [Play Mini Games Button]
    ↓
Game Selection Page
    ├─ Memory Game [Play]
    ├─ (Future Game 1) [Play]
    └─ (Future Game 2) [Play]
         ↓ [Player selects a game]
         ↓
       Selected Game
         ├─ [Player Wins] → Back to Game Selection
         │
         └─ [Player Skips] → Back to Game Selection
```

## Registry Pattern

```
GamesRegistry (singleton)
├── availableGames[]
│   ├── GameConfig (Memory Game)
│   │   ├── id: "memory_game"
│   │   ├── name: "Memory Game"
│   │   ├── description: "Match pairs..."
│   │   └── gamePageBuilder: (context, onWin, onSkip) → MemoryGamePage
│   │
│   ├── GameConfig (Future Game 1)
│   │   └── gamePageBuilder: (context, onWin, onSkip) → GameWidget1
│   │
│   └── GameConfig (Future Game 2)
│       └── gamePageBuilder: (context, onWin, onSkip) → GameWidget2
│
├── getRandomGame() ← Used during bingo gameplay
├── getGameById(id) ← Used in game selection page
└── availableGames ← Used to display game list
```

## Customization Points

### 1. Card Images
**File**: `lib/minigames/games_registry.dart` (line with cardImages parameter)
```dart
cardImages: const [ /* Your 20 items here */ ]
```

### 2. Add New Game
**File**: `lib/minigames/games_registry.dart` (in availableGames list)
```dart
GameConfig(
  id: 'your_game_id',
  name: 'Your Game',
  description: 'Description',
  gamePageBuilder: (context, onWin, onSkip) => YourGameWidget(...),
)
```

### 3. Game Trigger Frequency
**File**: `lib/main.dart` (in _BingoBoardPageState)
```dart
if (_checkedCount % 3 == 0) {  // ← Change 3 to any number
  _showMiniGame();
}
```

## Integration Points

### Main.dart Changes
- Imports games_registry.dart and game_selection_page.dart
- `_showMiniGame()` now calls `GamesRegistry.getRandomGame()`
- `ThankYouPage` navigates to `GameSelectionPage` instead of placeholder

### Game Requirements
Every game widget MUST:
1. Accept optional `onWin` callback → Call when player wins
2. Accept optional `onSkip` callback → Call when player skips
3. Return to previous screen when callback is invoked
4. Have a skip button with visible label

## Extensibility

The system is designed to easily support:
- ✅ Multiple games in registry
- ✅ Random game selection
- ✅ Different card images per game (future)
- ✅ Game difficulty levels (future)
- ✅ Game-specific settings/configuration (future)
- ✅ Game scoring/statistics (future)
- ✅ Game analytics (future)
