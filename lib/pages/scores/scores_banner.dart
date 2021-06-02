import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:flutter/material.dart';

class ScoresBanner extends StatelessWidget {
  const ScoresBanner({
    required this.context,
    required this.game,
    required this.creator,
    required this.players,
    required this.height,
  });

  final BuildContext context;
  final Game game;
  final List<Player> creator;
  final List<Player> players;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (game.practise == true) {
      return Container();
    } else {
      List<Player> playerList = [];
      playerList.addAll(creator);
      playerList.addAll(players);

      List<Player> winningPlayers = [];

      int maxScore = 0;
      playerList.forEach((Player player) {
        if (winningPlayers.length == 0) {
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
      });

      if (winningPlayers.length == 0) {
        return CircularProgressIndicator();
      } else if (winningPlayers.length == 1) {
        // Winner
        return Text('${winningPlayers[0].user!.displayName} WON!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else if (winningPlayers.length < playerList.length) {
        // DRAW
        return Text('It\'s a DRAW!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      } else {
        return Text('Waiting for all players...', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
      }
    }
  }
}
