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

    List<Player> gamePlayers = [Player(uid: uid)];
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

    //final FluggleUser fluggleUser = firebaseAuthService.fluggleUser!;
    //final String uid = fluggleUser.uid;

    List<Player> gamePlayers = [Player(uid: uid)];
    Map<String, PlayerStatus> playerUids = {};
    playerUids[uid] = PlayerStatus.invited;
    players?.forEach((AppUser user) {
      gamePlayers.add(Player(uid: user.uid));
      playerUids[user.uid] = PlayerStatus.invited;
    });

    Game game = Game(
      creatorId: uid,
      created: Timestamp.now(),
      gameStatus: gameStatus,
      playerUids: playerUids,
      players: gamePlayers,
      letters: _getShuffledLetters(),
    );

    // Only save if persist is true (by default).  Practise games are not saved
    if (persist!) {
      await firestoreDatabase.createGameWithTransaction(game);
    }

    return game;
  }

  void listGames(BuildContext context, {required String uid}) async {
    final firestoreDatabase = context.read(databaseProvider);
    firestoreDatabase.myPendingGamesStream;
  }

  void processWords(
    BuildContext context, {
    required Game game,
    required List<Player> creator,
    required List<Player> players,
    required Map<String, int> wordTally,
  }) async {
    final firestoreDatabase = context.read(databaseProvider);

    List<Player> playerList = [];
    playerList.addAll(creator);
    playerList.addAll(players);

    // Establish if all players have finished and scores have been uploaded
    List<bool> playersFinished = [];
    playerList.forEach((Player player) {
      if (player.creator) {
        playersFinished.add(true);
        // Already have the scores
      } else if (player.playerStatus == PlayerStatus.accepted) {
        // Waiting for score from this player
        playersFinished.add(false);
      } else if (player.playerStatus == PlayerStatus.finished) {
        playersFinished.add(true);
      }
    });

    playerList.forEach((Player player) {
      player.words!.forEach((String word, PlayerWord playerWord) {
        if (wordTally.containsKey(word)) {
          wordTally.update(word, (existingValue) => ++existingValue);
        } else {
          wordTally.putIfAbsent(word, () => 1);
        }
      });
    });

    // If all players have finished....
    if (!playersFinished.contains(false)) {
      if (game.gameStatus != GameStatus.finished) {
        // Now iterate through each players words and update
        playerList.forEach((Player player) {
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

          // Save Player
          firestoreDatabase.saveGamePlayer(game: game, player: player);
        });

/*        game.gameStatus = GameStatus.finished;
        firestoreDatabase.saveGame(game: game);*/
        // Player Scores have been updated
      }
    }
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
    List<List<String>> cubes = List.from(GAME_CUBES);

    for (var letterCube in cubes) {
      letterCube.shuffle();
    }
    cubes.shuffle();

    List<String> shuffledLetters = [];
    cubes.forEach((cube) => shuffledLetters.add(cube[0]));
    debugPrint('shuffledLetters: ${shuffledLetters}');
    return shuffledLetters;
  }
}
