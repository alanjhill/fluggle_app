import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/scores/scroll_utils.dart';
import 'package:flutter/material.dart';

class ScoresHeader extends StatelessWidget {
  ScoresHeader({
    required this.context,
    required this.game,
    required this.creator,
    required this.players,
    required this.height,
    required this.horizontalScrollerIndex,
    required this.horizontalScrollControllers,
  });

  final BuildContext context;
  final Game game;
  final List<Player> creator;
  final List<Player> players;
  final double height;
  final int horizontalScrollerIndex;
  final List<ScrollController> horizontalScrollControllers;

  @override
  Widget build(BuildContext context) {
    if (game.practise == true) {
      return Container();
    } else {
      List<Player> playerList = [];
      playerList.addAll(creator);
      playerList.addAll(players);

      return Container(
        padding: EdgeInsets.all(0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxWidth = constraints.maxWidth;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _playerScoresHeaderContent(
                  height: height,
                  width: maxWidth,
                  players: creator,
                  horizontalScrollerIndex: horizontalScrollerIndex,
                  first: true,
                ),
                _playerScoresHeaderContent(
                  height: height,
                  width: maxWidth,
                  players: players,
                  horizontalScrollerIndex: horizontalScrollerIndex,
                  first: false,
                ),
              ],
            );
          },
        ),
      );
    }
  }

  Widget _playerScoresHeaderContent({
    required List<Player> players,
    required double height,
    required double width,
    required bool first,
    required horizontalScrollerIndex,
  }) {
    final bool singlePlayer = game.practise!;
    if (singlePlayer) {
      width = width - 4;
    } else {
      width = width / 2 - 8;
    }
    return Expanded(
      child: Container(
          height: height,
          child: NotificationListener<ScrollEndNotification>(
            child: ListView.builder(
              controller: first ? null : horizontalScrollControllers[horizontalScrollerIndex],
              scrollDirection: Axis.horizontal,
              itemCount: players.length,
              itemBuilder: (context, index) {
                Player player = players[index];
                return Container(
                  margin: EdgeInsets.only(left: kSCORES_COLUMN_PADDING, right: kSCORES_COLUMN_PADDING),
                  padding: EdgeInsets.only(left: kSCORES_COLUMN_PADDING, right: kSCORES_COLUMN_PADDING),
                  width: width,
                  child: Text(
                    '${player.user!.displayName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
            onNotification: (scrollEnd) => ScrollUtils.scrollEndNotification(
              scrollMetrics: scrollEnd.metrics,
              width: width + (2 * kSCORES_COLUMN_PADDING),
              itemCount: players.length,
              horizontalScrollControllers: horizontalScrollControllers,
              horizontalScrollerIndex: horizontalScrollerIndex,
            ),
          )),
    );
  }
}
