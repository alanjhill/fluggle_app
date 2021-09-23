import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoresBanner extends ConsumerWidget {
  ScoresBanner({
    required this.game,
    required this.players,
    required this.height,
  });

  final Game game;
  final List<Player> players;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameService = ref.read(gameServiceProvider);

    if (game.practice == true) {
      return Container();
    } else {
      List<Player> winningPlayers = [];
      int maxScore = 0;
      for (var player in players) {
        if (winningPlayers.isEmpty) {
          winningPlayers.add(player);
          maxScore = player.score;
        } else {
          if (player.score == maxScore) {
            winningPlayers.add(player);
          } else if (player.score > maxScore) {
            winningPlayers.clear();
            winningPlayers.add(player);
            maxScore = player.score;
          }
        }
      }

      if (game.gameStatus != GameStatus.finished) {
        return Text('Game in progress', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else {}
      if (winningPlayers.length == 1) {
        // Winner
        return Text('${winningPlayers[0].user!.displayName} WON!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else if (winningPlayers.length == gameService.getNumPlayersFinished(game: game)) {
        // Draw
        return Text('It\'s a DRAW!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else {
        // Draw but not a draw between all players...do we need to identify which players?  Probably!
        return Text('It\'s a DRAW!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      }
    }
  }
}
