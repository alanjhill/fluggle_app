import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:flutter/material.dart';

class ScoresBanner extends StatelessWidget {
  const ScoresBanner({
    required this.context,
    required this.game,
    required this.players,
    required this.height,
  });

  final BuildContext context;
  final Game game;
  final List<Player> players;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (game.practise == true) {
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

      if (winningPlayers.isEmpty) {
        return CircularProgressIndicator();
      } else if (winningPlayers.length == 1) {
        // Winner
        return Text('${winningPlayers[0].user!.displayName} WON!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else if (winningPlayers.length < players.length) {
        // DRAW
        return Text('It\'s a DRAW!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else {
        return Text('Waiting for all players...', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      }
    }
  }
}
