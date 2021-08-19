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
  Game createPracticeGame(BuildContext context, {required int gameTime}) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final String? uid = user?.uid;

    List<Player> gamePlayers = [];
    Map<String, PlayerStatus> playerUids = {};
    if (uid != null) {
      gamePlayers.add(Player(playerId: uid));
      playerUids[uid] = PlayerStatus.accepted;
    }

    Game game = Game(
      creatorId: uid,
      created: Timestamp.now(),
      gameTime: gameTime,
      gameStatus: GameStatus.created,
      practice: true,
      playerUids: playerUids,
      players: gamePlayers,
      letters: _getShuffledLetters(),
    );

    return game;
  }

  Future<Game> createGame(BuildContext context, {required GameStatus gameStatus, List<AppUser>? players, required int gameTime, bool? persist = true}) async {
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
      gameTime: gameTime,
      gameStatus: gameStatus,
      practice: false,
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

  Future<void> saveGameAndPlayer(BuildContext context, {required Game game, required Player player}) async {
    final firestoreDatabase = context.read(databaseProvider);
    await firestoreDatabase.saveGameAndPlayer(game: game, player: player);
  }

  Future<void> saveGame(BuildContext context, {required Game game, required PlayerStatus playerStatus, required String uid}) async {
    final firestoreDatabase = context.read(databaseProvider);

    // Get the GameStatus
    GameStatus gameStatus = game.gameStatus!;

    // Update this player to declined / resigned
    game.playerUids[uid] = playerStatus;

    // If any players have not declined, resigned or finished, then the game is finished
    game.playerUids.forEach((String playerUid, PlayerStatus playerStatus) {
      if ([PlayerStatus.finished, PlayerStatus.resigned, PlayerStatus.declined].contains(playerStatus)) {
        game.gameStatus = GameStatus.finished;
      } else {
        game.gameStatus = gameStatus;
        // break out of the loop
        return;
      }
    });

    await firestoreDatabase.saveGame(game: game);
  }

  Future<void> _saveGameAndPlayers(BuildContext context, {required Game game, required List<Player> players}) async {
    final firestoreDatabase = context.read(databaseProvider);
    await firestoreDatabase.saveGameAndPlayers(game: game, players: players);
  }

  Future<void> deleteGame(BuildContext context, {required Game game}) async {
    final firestoreDatabase = context.read(databaseProvider);
    await firestoreDatabase.deleteGame(gameId: game.gameId!);
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
    // Establish if all players have finished and scores have been uploaded
    List<bool> playersFinished = _allPlayersFinished(game: game, players: players);

    // Update word tallys
    Map<String, int> wordTally = _getWordTally(players);

    // Sort the wordTallyMap
    LinkedHashMap<String, int> wordTallyMap = _sortWordTally(wordTally);

    // If all players have finished....
    //if (!playersFinished.contains(false)) {
    // If we haven't yet set the game status to finished
    if (game.gameStatus != GameStatus.finished) {
      // Now iterate through each players words and update
      for (var player in players) {
        if (true || game.playerUids[player.playerId] == PlayerStatus.finished) {
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
        }
      }

      if (game.practice == false) {
        // If all players have finished (or players have declined/resigned)
        if (!playersFinished.contains(false)) {
          // Update game status to finished and set finished time
          game.gameStatus = GameStatus.finished;
        }

        // Set the finished time for the last person to finish
        game.finished = Timestamp.now();

        // Save the Game and Players collection items
        _saveGameAndPlayers(context, game: game, players: players);
      }
    }
    //}

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
  ///   3. Alphabetical ordering
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

      // First sort on the number of points
      int comparePoints = valueA.compareTo(valueB);
      if (comparePoints != 0) return comparePoints * -1;

      // Then on word length
      int compareWordLength = wordALength.compareTo(wordBLength);
      if (compareWordLength != 0) return compareWordLength;

      // Then, alphabetically, on the word itself
      return wordA.compareTo(wordB) * -1;
    });

    // Add the sorted list to the LinkedHashMap
    for (var wordTally in wordTallyList.reversed) {
      wordTallyMap.putIfAbsent(wordTally.keys.elementAt(0), () => wordTally.values.elementAt(0));
    }

    return wordTallyMap;
  }

  List<bool> _allPlayersFinished({required Game game, required List<Player> players}) {
    List<bool> playersFinished = [];
    for (var player in players) {
      PlayerStatus? playerStatus = game.playerUids[player.playerId];
      if (player.creator) {
        playersFinished.add(true);
        // Already have the scores
      } else if (playerStatus == PlayerStatus.invited || playerStatus == PlayerStatus.accepted) {
        // Waiting for score from this player
        playersFinished.add(false);
      } else if (playerStatus == PlayerStatus.finished) {
        playersFinished.add(true);
      } else if (playerStatus == PlayerStatus.declined || playerStatus == PlayerStatus.resigned) {
        playersFinished.add(true);
      }
    }
    return playersFinished;
  }

  int getNumPlayersFinished({required Game game}) {
    int count = 0;
    game.playerUids.forEach((String playerId, PlayerStatus playerStatus) {
      if (playerStatus == PlayerStatus.finished) {
        count++;
      }
    });
    return count;
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
