# Bottle Order Game - Customization Guide

## 🎨 Customizing Bottle Colors

To change the bottle colors, edit `lib/minigames/bottle_order_game/bottle_order_game.dart`

### Available Colors in Flutter
```dart
Colors.red
Colors.blue
Colors.yellow
Colors.green
Colors.purple
Colors.orange
Colors.pink
Colors.teal
Colors.indigo
Colors.amber
// Or create custom colors:
Color(0xFFYourHexCode)
```

### Change Colors Example
```dart
// Line ~42 in the _availableColors list:
final List<BottleColor> _availableColors = [
  BottleColor(id: 1, color: Colors.red, name: 'Red'),
  BottleColor(id: 2, color: Colors.blue, name: 'Blue'),
  // Change to whatever you like!
];
```

---

## 🔧 Customizing Difficulty

### Change Number of Bottles
Simply modify initialization in `_initializeGame()`:
```dart
// Currently 5 bottles, change to:
List.generate(10, (index) => /* create bottle */)
// And update the GameConfig description
```

### Change Number of Attempts
```dart
// Line ~33:
int _attemptsLeft = 3;  // Change to any number
```

### Change Attempt Counter Display Color
```dart
// Line ~137:
color: Colors.orange,  // Change to any color
```

---

## 🎭 Customizing Appearance

### Barrier/Lock Icon
```dart
// Line ~198 - Change the lock icon:
Icon(Icons.lock,  // Try: Icons.visibility_off, Icons.lock_clock, etc.
```

### Barrier Color Darkness
```dart
// Line ~192 - Adjust opacity (0 = transparent, 1 = opaque):
color: Colors.black26,  // Currently 0.1 opacity (1/10)
// Try Colors.black12 for lighter, Colors.black45 for darker
```

### Bottle Size in Hidden Section
```dart
// Line ~186:
size: 50,  // Increase/decrease for larger/smaller display
```

### Bottle Size in User Section
```dart
// Line ~226:
size: 60,  // Increase/decrease for larger/smaller bottles
```

---

## ✏️ Customizing Text

All UI text can be found in the `build()` method and helper widgets:

### Title
```dart
// Line ~128:
title: const Text('Bottle Order Game'),
```

### Instruction Text
```dart
// Line ~139:
'Match the hidden bottles to their correct positions'
```

### Section Headers
```dart
// Line ~165:
'Hidden Bottles:'
// Line ~211:
'Your Bottles:'
```

### Button Labels
```dart
// Lines ~272-285:
'Restart'
'Submit Attempt'
'Skip Game'
```

### Status Messages
```dart
// Lines ~296-307:
'🎉 YOU WON! You matched all bottles correctly!'
'❌ Game Over! The bottles did not match.'
```

---

## 🎯 Advanced Customization

### Change Green Checkmark Icon
```dart
// Line ~258:
Icons.check  // Try: Icons.done_all, Icons.done, etc.
```

### Change Button Colors
```dart
// Lines ~278-282:
backgroundColor: Colors.blue,    // Restart button
backgroundColor: Colors.green,   // Submit button
backgroundColor: Colors.red,     // Skip button
```

### Adjust Animation Delays
```dart
// Lines ~92-95 (win delay):
Future.delayed(const Duration(milliseconds: 800), () {

// Lines ~98-99 (loss barrier delay):
Future.delayed(const Duration(milliseconds: 500), () {

// Line ~107 (final delay):
Future.delayed(const Duration(milliseconds: 1000), () {
```

### Change Bottle Shape
```dart
// Line ~370:
borderRadius: BorderRadius.circular(size * 0.15),
// Increase 0.15 for rounder, decrease for sharper
```

### Add Drop Shadow to Bottles
```dart
// Lines ~372-376 - Already implemented!
// To adjust shadow darkness/size:
boxShadow: [
  BoxShadow(
    color: bottle.color.withOpacity(0.5),  // Adjust 0.5
    blurRadius: 8,  // Increase for softer shadow
    offset: const Offset(2, 4),  // Adjust X, Y offset
  ),
],
```

---

## 🔗 Integration Points

### To Change When Game Is Triggered
Edit `lib/main.dart`:
```dart
if (_checkedCount % 3 == 0) {  // Currently every 3 boxes
  _showMiniGame();
}
```

### To Add Game to Different Registry
Edit `lib/minigames/games_registry.dart`:
```dart
GameConfig(
  id: 'bottle_order_game',
  name: 'Bottle Order',
  description: 'Match the hidden bottles to their correct positions',
  gamePageBuilder: (context, onWin, onSkip) => BottleOrderGamePage(
    onWin: onWin,
    onSkip: onSkip,
  ),
),
```

---

## 🐛 Debugging Tips

### Enable Logs
Add print statements in key methods:
```dart
void _onSubmitAttempt() {
  print('Attempt submitted. Correct positions: $_correctPositions');
  print('Attempts left: $_attemptsLeft');
  // ... rest of code
}
```

### Check Bottle Matching Logic
```dart
void _updateCorrectPositions() {
  for (int i = 0; i < 5; i++) {
    print('Position $i: User=${_userBottles[i].id}, Hidden=${_hiddenBottles[i].id}');
    _correctPositions[i] = _userBottles[i].id == _hiddenBottles[i].id;
  }
}
```

### Verify Game State
Add during build method:
```dart
// Temporarily add to body to debug:
Text('Attempts: $_attemptsLeft, Won: $_won, BarrierRemoved: $_barrierRemoved')
```

---

## 📋 Testing Checklist

- [ ] Bottles display correctly with assigned colors
- [ ] Tapping bottles opens swap dialog
- [ ] Swapping works correctly
- [ ] Green checkmarks appear on correct positions
- [ ] Attempt counter decrements
- [ ] Game recognizes win condition (all 5 correct)
- [ ] Barrier removes when game ends
- [ ] Win message displays on win
- [ ] Loss message displays on loss
- [ ] onWin() called on successful match
- [ ] onSkip() called on failed attempts or skip
- [ ] Restart button reshuffles bottles
- [ ] Game appears in minigames registry
- [ ] Game available during gameplay (every 3 boxes)
- [ ] Game available in game selection

