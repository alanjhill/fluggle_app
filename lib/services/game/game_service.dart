import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/game_letters.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameService {
  Future<Game> createGame(BuildContext context, {required GameStatus gameStatus, List<FluggleUser>? players, bool? persist = true}) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context, listen: false);

    final user = await authService.currentUser();
    final String uid = user.uid;

    List<Player> gamePlayers = [Player(uid: uid)];
    List<String> playerUids = [uid];
    players?.forEach((FluggleUser user) {
      gamePlayers.add(Player(uid: user.uid, status: PlayerStatus.invited));
      playerUids.add(user.uid);
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
    //final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreGameDatabase = Provider.of<FirestoreDatabase>(context, listen: false);

    firestoreGameDatabase.myPendingGamesStream();
  }

  void processWords(BuildContext context, {required String gameId, required List<Player> playerList, required Map<String, int> wordTally}) async {
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context, listen: false);

    // Establish if all players have finished and scores have been uploaded
    List<bool> playersFinished = [];
    playerList.forEach((Player player) {
      if (player.creator) {
        playersFinished.add(true);
        // Already have the scores
      } else if (player.status == PlayerStatus.accepted) {
        // Waiting for score from this player
        playersFinished.add(false);
      } else if (player.status == PlayerStatus.finished) {
        playersFinished.add(true);
      }
    });

    // Tally of words and word count
    playerList.forEach((Player player) {
      player.words!.forEach((String word, PlayerWord playerWord) {
        if (wordTally.containsKey(word)) {
          wordTally.update(word, (existingValue) => ++existingValue);
        } else {
          wordTally.putIfAbsent(word, () => 1);
        }
      });
    });

    Game game = await firestoreDatabase.getGame(gameId: gameId);
    debugPrint('gameStatus: ${game.gameStatus.toString()}');

    if (!playersFinished.contains(false)) {
      if (game.gameStatus != GameStatus.finished) {
        // Now iterate through each players words and update
        playerList.forEach((Player player) async {
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
          await firestoreDatabase.saveGamePlayer(game: game, player: player);
        });

        game.gameStatus = GameStatus.finished;
        await firestoreDatabase.saveGame(game: game);
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
