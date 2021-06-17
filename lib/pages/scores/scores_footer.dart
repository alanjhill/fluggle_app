import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/pages/scores/scroll_utils.dart';
import 'package:flutter/material.dart';

class ScoresFooter extends StatelessWidget {
  ScoresFooter({
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
    List<Player> playerList = [];
    playerList.addAll(creator);
    playerList.addAll(players);

    return Container(
      padding: EdgeInsets.all(0.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildPlayersScoresFooterContent(
                height: height,
                width: maxWidth,
                players: creator,
                horizontalScrollerIndex: horizontalScrollerIndex,
                first: true,
              ),
              _buildPlayersScoresFooterContent(
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

  Widget _buildPlayersScoresFooterContent({
    required List<Player> players,
    required double height,
    required double width,
    required bool first,
    required horizontalScrollerIndex,
  }) {
    return Expanded(
      child: Container(
        height: height,
        child: NotificationListener<ScrollEndNotification>(
            child: ListView.builder(
              controller: first ? null : horizontalScrollControllers[horizontalScrollerIndex],
              scrollDirection: Axis.horizontal,
              itemCount: players.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(left: 4, right: 4),
                  padding: EdgeInsets.only(left: 4.0, right: 4.0),
                  height: 100,
                  width: width / 2 - 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _score(player: players[index]),
                      ..._wordCounts(player: players[index]),
                    ],
                  ),
                );
              },
            ),
            onNotification: (scrollEnd) => ScrollUtils.scrollEndNotification(
                scrollMetrics: scrollEnd.metrics,
                width: width,
                horizontalScrollControllers: horizontalScrollControllers,
                horizontalScrollerIndex: horizontalScrollerIndex)),
      ),
    );
  }

  Widget _score({required Player player}) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Text(
              'Score',
              textAlign: TextAlign.left,
            ),
          ),
          Text(
            '${player.score}',
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  /// Total Words and Unique Words
  List<Widget> _wordCounts({required Player player}) {
    int wordCount = 0;
    int uniqueWordCount = 0;

    player.words!.forEach((String word, PlayerWord playerWord) {
      wordCount++;
      if (playerWord.gameWord.unique == true) {
        uniqueWordCount++;
      }
    });

    List<Widget> rows = [];

    // Total Words
    rows.add(
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(child: AutoSizeText('Total words:', maxLines: 1, textAlign: TextAlign.left)),
            AutoSizeText('${wordCount}', textAlign: TextAlign.right),
          ],
        ),
      ),
    );

    /// Only show the Unique Words if this is a real game
    if (game.practise == false) {
      // Unique Words
      rows.add(
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(child: AutoSizeText('Unique words:', maxLines: 1, textAlign: TextAlign.left)),
              AutoSizeText('${uniqueWordCount}', textAlign: TextAlign.right),
            ],
          ),
        ),
      );
    }
    return rows;
  }
}
