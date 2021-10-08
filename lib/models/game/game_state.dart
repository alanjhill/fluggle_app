import 'dart:collection';

import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/utils/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WordStatus { empty, valid, invalid, duplicate }

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) => GameStateNotifier(
    const GameState(),
  ),
);

@immutable
class GameState {
  final List<GridItem> swipedGridItems;
  final Map<String, PlayerWord> addedWords;
  final String currentWord;
  final WordStatus currentWordStatus;
  final bool gameStarted;
  final bool gamePaused;
  final bool timerEnded;

  const GameState({
    this.swipedGridItems = const [],
    this.addedWords = const {},
    this.currentWord = "",
    this.currentWordStatus = WordStatus.empty,
    this.gameStarted = false,
    this.gamePaused = false,
    this.timerEnded = false,
  });

  GameState copyWith({
    List<GridItem>? swipedGridItems,
    Map<String, PlayerWord>? addedWords,
    String? currentWord,
    WordStatus? currentWordStatus,
    bool? gameStarted,
    bool? gamePaused,
    final bool? timerEnded,
  }) {
    debugPrint('>>> currentWordStatus: $currentWordStatus}');
    return GameState(
      swipedGridItems: swipedGridItems ?? this.swipedGridItems,
      addedWords: addedWords ?? this.addedWords,
      currentWord: currentWord ?? this.currentWord,
      currentWordStatus: currentWordStatus ?? this.currentWordStatus,
      gameStarted: gameStarted ?? this.gameStarted,
      gamePaused: gamePaused ?? this.gamePaused,
      timerEnded: timerEnded ?? this.timerEnded,
    );
  }

  @override
  String toString() {
    return 'GameState{swipedGridItems: $swipedGridItems, _addedWords: $addedWords, _currentWord: $currentWord, currentWordStatus: $currentWordStatus, gameStarted: $gameStarted, _gamePaused: $gamePaused, _timerEnded: $timerEnded}';
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier(GameState state) : super(state);

  bool addSwipedGridItem(GridItem gridItem) {
    bool added = false;

    List<GridItem> swipedGridItems = state.swipedGridItems;
    GridItem? lastAddedGridItem = swipedGridItems.isNotEmpty ? swipedGridItems.last : null;
    if (!swipedGridItems.contains(gridItem) && (gridItem.isAdjacent(lastAddedGridItem) || isFirstItem)) {
      swipedGridItems.add(gridItem);
      added = true;
    }
    debugPrint('_addSwipedGridItem, added; $added');
    state = state.copyWith(swipedGridItems: swipedGridItems, currentWordStatus: WordStatus.empty, currentWord: "");
    return added;
  }

  Map<String, PlayerWord> get addedWords => state.addedWords;

  void addWord(Dictionary dictionary) {
    String word = "";
    for (GridItem gridItem in state.swipedGridItems) {
      word += gridItem.letter;
    }
    Map<String, PlayerWord> addedWords = state.addedWords;
    WordStatus? currentWordStatus = state.currentWordStatus;

    // Add the word to the list of words if it does not exist
    if (word.length >= 3) {
      // Check if word exists in dictionary
      if (dictionary.exists(state.currentWord)) {
        if (!addedWords.containsKey(word)) {
          addedWords[word] = PlayerWord(gameWord: GameWord(word: word), gridItems: state.swipedGridItems);
          currentWordStatus = WordStatus.valid;
        } else {
          currentWordStatus = WordStatus.duplicate;
        }
      } else {
        // Doesn't exist in dictionary, invalid
        currentWordStatus = WordStatus.invalid;
      }
    } else {
      // Word is too short
      currentWordStatus = WordStatus.invalid;
    }

    state = state.copyWith(addedWords: addedWords, currentWord: word, currentWordStatus: currentWordStatus);
    debugPrint(state.toString());

    // Reset the swiped items
    resetGridItems();
  }

  void resetGridItems() {
    List<GridItem> swipedGridItems = [...state.swipedGridItems];
    for (var gridItem in swipedGridItems) {
      gridItem.swiped = false;
    }
    state = state.copyWith(swipedGridItems: swipedGridItems);
  }

  bool get isFirstItem => state.swipedGridItems.isEmpty;

  void resetSwipedItems() {
    state = state.copyWith(swipedGridItems: []);
  }

  void resetWords() {
    state = state.copyWith(addedWords: {});
  }

  List<GridItem> get swipedGridItems => state.swipedGridItems;

  void updateCurrentWord() {
    String currentWord = "";
    for (GridItem gridItem in state.swipedGridItems) {
      currentWord += gridItem.letter;
      debugPrint('currentWord: ${state.currentWord}');
    }
    debugPrint('currentWord: ${state.currentWord}');

    state = state.copyWith(currentWord: currentWord);
  }

  void toggleGamePaused() {
    state = state.copyWith(gamePaused: !state.gamePaused);
  }

  void startGame() {
    state = state.copyWith(gameStarted: true);
  }

  void quitGame() {
    state = state.copyWith(gameStarted: false);
  }

  void reset() {
    state = state.copyWith(
      swipedGridItems: [],
      addedWords: {},
      currentWord: "",
      currentWordStatus: WordStatus.empty,
      gameStarted: false,
      gamePaused: false,
      timerEnded: false,
    );
  }

  void endTimer() {
    state = state.copyWith(
      gamePaused: false,
      timerEnded: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
