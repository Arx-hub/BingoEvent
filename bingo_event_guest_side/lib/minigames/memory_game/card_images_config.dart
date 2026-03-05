// Configuration examples for Memory Game card images
// 
// This file shows how to customize the Memory Game with different card sets.
// You can use this as a reference when you want to replace the default emoji cards.
/// Simply update the cardImages list in games_registry.dart with one of these examples,
/// or create your own custom list.

// Example 1: Fruit emojis (default)
const List<String> fruitCards = [
  '🍎', '🍌', '🍊', '🍋', '🍉',
  '🍒', '🍑', '🍐', '🥝', '🍍',
  '🍎', '🍌', '🍊', '🍋', '🍉',
  '🍒', '🍑', '🍐', '🥝', '🍍',
];

// Example 2: Animal emojis
const List<String> animalCards = [
  '🐶', '🐱', '🐭', '🐹', '🐰',
  '🦊', '🐻', '🐼', '🐨', '🐯',
  '🐶', '🐱', '🐭', '🐹', '🐰',
  '🦊', '🐻', '🐼', '🐨', '🐯',
];

// Example 3: Sport emojis
const List<String> sportCards = [
  '⚽', '🏀', '🏈', '⚾', '🎾',
  '🏐', '🏉', '🥎', '🏏', '🏑',
  '⚽', '🏀', '🏈', '⚾', '🎾',
  '🏐', '🏉', '🥎', '🏏', '🏑',
];

// Example 4: Image assets (if you want to use custom images)
// First, add your images to: assets/images/
// Then uncomment and use this format:
/*
const List<String> imageCards = [
  'assets/images/card1.png',
  'assets/images/card2.png',
  'assets/images/card3.png',
  'assets/images/card4.png',
  'assets/images/card5.png',
  'assets/images/card6.png',
  'assets/images/card7.png',
  'assets/images/card8.png',
  'assets/images/card9.png',
  'assets/images/card10.png',
  'assets/images/card1.png',
  'assets/images/card2.png',
  'assets/images/card3.png',
  'assets/images/card4.png',
  'assets/images/card5.png',
  'assets/images/card6.png',
  'assets/images/card7.png',
  'assets/images/card8.png',
  'assets/images/card9.png',
  'assets/images/card10.png',
];
*/

// How to use:
// 1. Copy the list you want to use
// 2. Go to games_registry.dart
// 3. Find the Memory Game GameConfig in the availableGames list
// 4. Update the cardImages parameter in the gamePageBuilder:
//
//    GameConfig(
//      id: 'memory_game',
//      name: 'Memory Game',
//      description: 'Match pairs of cards by memory',
//      gamePageBuilder: (context, onWin, onSkip) => MemoryGamePage(
//        onWin: onWin,
//        onSkip: onSkip,
//        cardImages: animalCards,  // <-- Change this
//      ),
//    ),
