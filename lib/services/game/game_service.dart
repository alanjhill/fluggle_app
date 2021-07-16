import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/game_letters.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameService {
  Game createPracticeGame(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;
    final String uid = user.uid;

    List<Player> gamePlayers = [Player(playerId: uid)];
    Map<String, PlayerStatus> playerUids = {};
    playerUids[uid] = PlayerStatus.accepted;

    Game game = Game(
      creatorId: uid,
      created: Timestamp.now(),
      gameStatus: GameStatus.created,
      practise: true,
      playerUids: playerUids,
      players: gamePlayers,
      letters: _getShuffledLetters(),
    );

    return game;
  }

  Future<Game> createGame(BuildContext context, {required GameStatus gameStatus, List<AppUser>? players, bool? persist = true}) async {
    final firestoreDatabase = context.read(databaseProvider);
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;
    final String uid = user.uid;

    List<Player> gamePlayers = [Player(playerId: uid)];
    Map<String, PlayerStatus> playerUids = {};
    playerUids[uid] = PlayerStatus.invited;
    for (var user in players!) {
      gamePlayers.add(Player(playerId: user.uid));
      playerUids[user.uid] = PlayerStatus.invited;
    }

    Game game = Game(
      creatorId: uid,
      created: Timestamp.now(),
      gameStatus: gameStatus,
      practise: false,
      playerUids: playerUids,
      players: gamePlayers,
      letters: _getShuffledLetters(),
    );

    // Only save if persist is true (by default).  practice games are not saved
    if (persist!) {
      await firestoreDatabase.createGame(game: game);
    }

    return game;
  }

  Future<void> saveGame(BuildContext context, {required Game game}) async {
    final firestoreDatabase = context.read(databaseProvider);
    await firestoreDatabase.saveGame(game: game);
    return;
  }

  void listGames(BuildContext context, {required String uid}) async {
    final firestoreDatabase = context.read(databaseProvider);
    firestoreDatabase.myPendingGamesStream;
  }

  LinkedHashMap<String, int> processWords(
    BuildContext context, {
    required Game game,
    required List<Player> players,
  }) {
    final firestoreDatabase = context.read(databaseProvider);

    // Establish if all players have finished and scores have been uploaded
    List<bool> playersFinished = _allPlayersFinished(players);

    // Update word tallys
    Map<String, int> wordTally = _getWordTally(players);

    // Sort the wordTallyMap
    LinkedHashMap<String, int> wordTallyMap = _sortWordTally(wordTally);

    // If all players have finished....
    if (!playersFinished.contains(false)) {
      if (game.gameStatus != GameStatus.finished) {
        // Now iterate through each players words and update
        for (var player in players) {
          int playerScore = 0;
          player.words!.forEach((String word, PlayerWord playerWord) {
            int? count = wordTally[word];
            if (count == 1) {
              playerWord.gameWord.unique = true;
              playerWord.gameWord.score = _getScore(word);
            } else {
              playerWord.gameWord.unique = false;
              playerWord.gameWord.score = 0;
            }
            playerScore += playerWord.gameWord.score!;
          });
          player.score = playerScore;

          // If this is a real game (i.e. not practice) then save the game and player
          // TODO: Potentially make this a transaction to read data first to check status of each player...?
          if (game.practise == false) {
            // Update game status to finished
            game.gameStatus = GameStatus.finished;
            game.finished = Timestamp.now();
            // Save Game and Player
            for (var player in players) {
              firestoreDatabase.saveGameAndPlayer(game: game, player: player);
            }
          }
        }
      }
    }

    return wordTallyMap;
  }

  Map<String, int> _getWordTally(List<Player> players) {
    Map<String, int> wordTally = {};
    for (var player in players) {
      player.words!.forEach((String word, PlayerWord playerWord) {
        if (wordTally.containsKey(word)) {
          wordTally.update(word, (existingValue) => ++existingValue);
        } else {
          wordTally.putIfAbsent(word, () => 1);
        }
      });
    }
    return wordTally;
  }

  /// Sort the words based on;
  ///   1. Being unique
  ///   2. Word length
  ///   3. Alphabetcial ordering
  LinkedHashMap<String, int> _sortWordTally(Map<String, int> wordTally) {
    List<Map<String, int>> wordTallyList = [];
    LinkedHashMap<String, int> wordTallyMap = LinkedHashMap();

    // Add the map of words to a list
    wordTally.forEach((String word, int value) {
      wordTallyList.add({word: value});
    });

    // Sort the words
    wordTallyList.sort((a, b) {
      var wordA = a.keys.elementAt(0);
      var wordALength = wordA.length;
      var valueA = a.values.elementAt(0);

      var wordB = b.keys.elementAt(0);
      var wordBLength = wordB.length;
      var valueB = b.values.elementAt(0);

      //if (valueA == 1) return 1;
      //if (valueB == 1) return -1;
      // First sort on the number of points
      int comparePoints = valueA.compareTo(valueB);
      if (comparePoints != 0) return comparePoints * -1;

      // Then on word length
      int compareWordLength = wordALength.compareTo(wordBLength);
      if (compareWordLength != 0) return compareWordLength;

      // Then, aphabetically, on the word itself
      return wordA.compareTo(wordB) * -1;
    });

    // Add the sorted list to the LinkedHashMap
    for (var wordTally in wordTallyList.reversed) {
      wordTallyMap.putIfAbsent(wordTally.keys.elementAt(0), () => wordTally.values.elementAt(0));
    }

    return wordTallyMap;
  }

  List<bool> _allPlayersFinished(List<Player> playerList) {
    List<bool> playersFinished = [];
    for (var player in playerList) {
      if (player.creator) {
        playersFinished.add(true);
        // Already have the scores
      } else if (player.playerStatus == PlayerStatus.accepted) {
        // Waiting for score from this player
        playersFinished.add(false);
      } else if (player.playerStatus == PlayerStatus.finished) {
        playersFinished.add(true);
      }
    }
    return playersFinished;
  }

  /// Get the score based on the word length
  int _getScore(String word) {
    int score = 0;
    if (word.length == 3) {
      score = 1;
    } else if (word.length == 4) {
      score = 1;
    } else if (word.length == 5) {
      score = 2;
    } else if (word.length == 6) {
      score = 3;
    } else if (word.length == 7) {
      score = 4;
    } else {
      score = 11;
    }
    return score;
  }

  List<String> _getShuffledLetters() {
    List<List<String>> cubes = List.from(kGameCubes);

    for (var letterCube in cubes) {
      letterCube.shuffle();
    }
    cubes.shuffle();

    List<String> shuffledLetters = [];
    for (var cube in cubes) {
      shuffledLetters.add(cube[0]);
    }
    return shuffledLetters;
  }
}
