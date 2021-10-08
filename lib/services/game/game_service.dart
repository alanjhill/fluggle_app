import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_state.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/game_letters.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playerStreamProvider = StreamProvider.autoDispose.family<List<Player>, String>((ref, String gameId) {
  final database = ref.watch(databaseProvider);
  final vm = GameViewModel(database: database!);
  return vm.gamePlayersStream(gameId: gameId, includeSelf: false);
});

final gameServiceProvider = Provider<GameService>((ref) => throw UnimplementedError());

class GameService {
  /// Create a game for paractise use but do not save to the db
  Game createPracticeGame(WidgetRef ref, {required List<Player> players, required int gameTime}) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final String? uid = user?.uid;

    Map<String, PlayerStatus> playerUids = {};
    if (uid != null) {
      players.add(Player(playerId: uid));
      playerUids[uid] = PlayerStatus.accepted;
    }

    Game game = Game(
      creatorId: uid,
      created: Timestamp.now(),
      gameTime: gameTime,
      gameStatus: GameStatus.created,
      practice: true,
      playerUids: playerUids,
      letters: _getShuffledLetters(),
    );

    return game;
  }

  /// Create Players from AppUsers
  List<Player> createPlayersFromAppUsers(WidgetRef ref, {required List<AppUser> appUsers}) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final String? uid = user?.uid;

    List<Player> players = [Player(playerId: uid!)];
    for (var appUser in appUsers) {
      players.add(Player(playerId: appUser.uid));
    }

    return players;
  }

  /// Create a game and persist to the db
  Future<Game> createGame(WidgetRef ref,
      {required GameStatus gameStatus, required List<Player> players, required Map<String, PlayerStatus> playerUids, required int gameTime}) async {
    final firestoreDatabase = ref.read(databaseProvider);
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;
    final String uid = user.uid;

    Game game = Game(
      creatorId: uid,
      created: Timestamp.now(),
      gameTime: gameTime,
      gameStatus: gameStatus,
      practice: false,
      playerUids: playerUids,
      letters: _getShuffledLetters(),
    );

    await firestoreDatabase!.createGame(game: game, players: players);

    return game;
  }

  /// Save the Game and Player to the db
  Future<void> saveGameAndPlayer(WidgetRef ref, {required Game game, required Player player}) async {
    final firestoreDatabase = ref.read(databaseProvider);
    await firestoreDatabase!.saveGameAndPlayer(game: game, player: player);
  }

  /// Just save the game for this user
  Future<void> saveGame(WidgetRef ref, {required Game game, required PlayerStatus playerStatus, required String uid}) async {
    final firestoreDatabase = ref.read(databaseProvider);

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

    await firestoreDatabase!.saveGame(game: game);
  }

  Future<void> _saveGameAndPlayers(WidgetRef ref, {required Game game, required List<Player> players}) async {
    debugPrint('>>> _saveGameAndPlayers, ref: $ref');
    final firestoreDatabase = ref.read(databaseProvider);
    await firestoreDatabase!.saveGameAndPlayers(game: game, players: players);
    debugPrint('<<< _saveGameAndPlayers');
  }

  Future<void> deleteGame(WidgetRef ref, {required Game game}) async {
    final firestoreDatabase = ref.read(databaseProvider);
    await firestoreDatabase!.deleteGame(gameId: game.gameId!);
  }

  void listGames(WidgetRef ref, {required String uid}) async {
    final firestoreDatabase = ref.read(databaseProvider);
    firestoreDatabase!.myPendingGamesStream;
  }

  Future<void> playerFinished(WidgetRef ref, {required Game game, required Player player, required String uid}) async {
    debugPrint('>>> PlayerFinished >>>');
    final gameState = ref.read(gameStateProvider);

    // If practice mode, we don't save anything, just redirect to the scores page, passing the game object
    if (game.practice == true) {
      // Set the words for this player
      player.words = LinkedHashMap.from(gameState.addedWords);
      game.playerUids[player.playerId] = PlayerStatus.finished;

      // Process the words
      List<Player> players = [player];
      _processWords(ref, game: game, players: players);
    } else {
      // Multiplayer game...save the words for this player and process the words for all players
      final firestoreDatabase = ref.read(databaseProvider);

      // Set the words for this player
      player.words = LinkedHashMap.from(gameState.addedWords);

      // Create a list of players
      List<Player> players = [];
      players.add(player);
      for (var playerUid in game.playerUids.keys) {
        if (playerUid != uid) {
          debugPrint('>>> await firestoreDatabase');
          Player p = await firestoreDatabase!.getGamePlayer(gameId: game.gameId!, playerUid: playerUid);
          debugPrint('<<< await firestoreDatabase');
          players.add(p);
        }
      }

      // Set the status of this player to finished
      game.playerUids[uid] = PlayerStatus.finished;

      // Process the words
      _processWords(ref, game: game, players: players);
    }
    debugPrint('<<< PlayerFinished <<<');
  }

  Future<void> _processWords(
    WidgetRef ref, {
    required Game game,
    required List<Player> players,
  }) async {
    debugPrint('>>> processWords: ${DateTime.now()}');
    // Establish if all players have finished and scores have been uploaded
    List<bool> playersFinished = _allPlayersFinished(game: game, players: players);

    // Get word tallys
    Map<String, int> wordTally = getWordTally(game: game, players: players);

    // If the game is not yet finished...
    if (game.gameStatus != GameStatus.finished) {
      // Now iterate through each players words and update
      for (var player in players) {
        // ...and if player is finished, update the GameWord data
        if (game.playerUids[player.playerId] == PlayerStatus.finished) {
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

      // For a practice game, do not need to update the game status or persist
      if (game.practice == false) {
        // If all players have finished (or players have declined/resigned)
        if (!playersFinished.contains(false)) {
          // Update game status to finished and set finished time
          game.gameStatus = GameStatus.finished;
        }

        // Set the finished time for the last person to finish
        game.finished = Timestamp.now();

        // Save the Game and Players collection items
        await _saveGameAndPlayers(ref, game: game, players: players);
      }
      debugPrint('<<< processWords: ${DateTime.now()}');
    }
  }

  /// Get the word tally for all players
  Map<String, int> getWordTally({required Game game, required List<Player> players}) {
    Map<String, int> wordTally = {};
    for (var player in players) {
      if (game.playerUids[player.playerId] == PlayerStatus.finished) {
        player.words!.forEach((String word, PlayerWord playerWord) {
          if (wordTally.containsKey(word)) {
            wordTally.update(word, (existingValue) => ++existingValue);
          } else {
            wordTally.putIfAbsent(word, () => 1);
          }
        });
      }
    }
    return wordTally;
  }

  /// Sort the words based on;
  ///   1. Being unique
  ///   2. Word length
  ///   3. Alphabetical ordering
  LinkedHashMap<String, int> sortWordTally(Map<String, int> wordTally) {
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

  /// Check if all players have finished
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
