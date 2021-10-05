import 'dart:collection';

import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/utils/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WordStatus { empty, valid, invalid, duplicate }

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
    (ref) => GameStateNotifier());

class GameState {
  late List<GridItem> swipedGridItems;
  late LinkedHashMap<String, PlayerWord> addedWords;
  late String currentWord;
  late WordStatus currentWordStatus;
  late bool gameStarted;
  late bool gamePaused;
  late bool timerEnded;

  void reset() {
    swipedGridItems = [];
    addedWords = LinkedHashMap<String, PlayerWord>();
    currentWord = "";
    currentWordStatus = WordStatus.empty;
    gameStarted = false;
    gamePaused = false;
    timerEnded = false;
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState());

  bool addSwipedGridItem(GridItem gridItem) {
    bool added = false;
    state.currentWord = "";
    state.currentWordStatus = WordStatus.empty;
    GridItem? lastAddedGridItem =
        state.swipedGridItems.isNotEmpty ? state.swipedGridItems.last : null;
    if (!state.swipedGridItems.contains(gridItem) &&
        (gridItem.isAdjacent(lastAddedGridItem) || isFirstItem())) {
      state.swipedGridItems.add(gridItem);
      added = true;
    }
    debugPrint('_addSwipedGridItem, added; $added');
    state = state;
    return added;
  }

  LinkedHashMap<String, PlayerWord> get addedWords => state.addedWords;

  //bool get gameStarted => state.gameStarted;

  //bool get timerEnded => state.timerEnded;

  void addWord(Dictionary dictionary) {
    String word = "";
    for (GridItem gridItem in state.swipedGridItems) {
      word += gridItem.letter;
    }

    // Set the current word
    state.currentWord = word;

    // Add the word to the list of words if it does not exist
    if (word.length >= 3) {
      // Check if word exists in dictionary
      if (dictionary.exists(state.currentWord)) {
        if (!state.addedWords.containsKey(word)) {
          state.addedWords[word] = PlayerWord(
              gameWord: GameWord(word: word), gridItems: state.swipedGridItems);
          state.currentWordStatus = WordStatus.valid;
        } else {
          state.currentWordStatus = WordStatus.duplicate;
        }
      } else {
        // Doesn't exist in dictionary, invalid
        state.currentWordStatus = WordStatus.invalid;
      }
    } else {
      // Word is too short
      state.currentWordStatus = WordStatus.invalid;
    }

    // Reset the swiped items
    resetGridItems();
  }

  void resetGridItems() {
    for (var gridItem in state.swipedGridItems) {
      gridItem.swiped = false;
    }
    state = state;
  }

  bool isFirstItem() {
    return state.swipedGridItems.isEmpty;
  }

  void resetSwipedItems() {
    state.swipedGridItems.clear();
  }

  List<GridItem> getSwipedGridItems() {
    return state.swipedGridItems;
  }

  void updateCurrentWord() {
    String currentWord = "";
    for (GridItem gridItem in state.swipedGridItems) {
      currentWord += gridItem.letter;
      debugPrint('currentWord: ${state.currentWord}');
    }
    state.currentWord = currentWord;
    debugPrint('currentWord: ${state.currentWord}');
    state = state;
  }

  void toggleGamePaused() {
    state.gamePaused = !state.gamePaused;
    state = state;
  }

  void reset() {
    state.reset();
    //state = state;
  }

  void endTimer() {
    state.timerEnded = true;
    state = state;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
