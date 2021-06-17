import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/pages/scores/scores_item.dart';
import 'package:fluggle_app/pages/scores/scroll_utils.dart';
import 'package:flutter/material.dart';

class Scores extends StatelessWidget {
  Scores({
    required this.context,
    required this.game,
    required this.creator,
    required this.players,
    required this.wordTally,
    required this.height,
    required this.horizontalScrollerIndex,
    required this.horizontalScrollControllers,
    required this.verticalScrollControllers,
  });

  final BuildContext context;
  final Game game;
  final List<Player> creator;
  final List<Player> players;
  final Map<String, int> wordTally;
  final double height;
  final int horizontalScrollerIndex;
  final List<ScrollController> horizontalScrollControllers;
  final List<ScrollController> verticalScrollControllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          //debugPrint('constraints: ${constraints}');
          double maxWidth = constraints.maxWidth;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildPlayersScoresContent(
                game: game,
                players: creator,
                height: height,
                width: maxWidth,
                wordTally: wordTally,
                horizontalScrollerIndex: horizontalScrollerIndex,
                first: true,
              ),
              _buildPlayersScoresContent(
                game: game,
                players: players,
                height: height,
                width: maxWidth,
                wordTally: wordTally,
                horizontalScrollerIndex: horizontalScrollerIndex,
                first: false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayersScoresContent({
    required Game game,
    required List<Player> players,
    required Map<String, int> wordTally,
    required double height,
    required double width,
    required bool first,
    required int horizontalScrollerIndex,
  }) {
    return Expanded(
      child: Container(
        height: height,
        child: NotificationListener<ScrollEndNotification>(
          child: ListView.builder(
            shrinkWrap: true,
            controller: first ? null : horizontalScrollControllers[horizontalScrollerIndex],
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            itemBuilder: (context, index) {
              return Container(
                height: height,
                margin: EdgeInsets.only(left: 4, right: 4, bottom: 4),
                padding: EdgeInsets.only(bottom: 2),
                width: width / 2 - 8,
                decoration: BoxDecoration(
                  color: kFluggleBoardBackgroundColor,
                  border: Border.all(width: 2.0, color: Colors.white),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _buildPlayerScoresList(
                  context,
                  game: game,
                  creator: players,
                  playerIndex: index,
                  verticalScrollerIndex: first ? 0 : index + 1,
                  wordTally: wordTally,
                  switched: false,
                  scrollControllers: verticalScrollControllers,
                ),
              );
            },
          ),
          onNotification: (scrollEnd) => ScrollUtils.scrollEndNotification(
            scrollMetrics: scrollEnd.metrics,
            width: width,
            horizontalScrollControllers: horizontalScrollControllers,
            horizontalScrollerIndex: horizontalScrollerIndex,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScoresList(
    BuildContext context, {
    required Game game,
    required int playerIndex,
    required int verticalScrollerIndex,
    required Map<String, int> wordTally,
    required bool switched,
    required List<ScrollController> scrollControllers,
    List<Player>? creator,
    List<Player>? players,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    debugPrint('width: ${width}');

    final double borderWidth = 2.0;
    final double headerHeight = 24.0;

    List<Player> playerList = [];
    if (creator != null) {
      playerList.addAll(creator);
    } else if (players != null) {
      playerList.addAll(players);
    }

    final Player player = playerList[playerIndex];
    final PlayerStatus playerStatus = game.playerUids![player.playerId] as PlayerStatus;

    if (true || playerStatus == PlayerStatus.finished) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            child: ListView.builder(
              controller: verticalScrollControllers[verticalScrollerIndex],
              itemCount: wordTally.length,
              itemBuilder: (context, index) {
                String word = wordTally.keys.elementAt(index);
                if (player.words![word] != null) {
                  return ScoresItem(playerWord: player.words![word]!, switched: switched);
                } else {
                  return ScoresItem(playerWord: PlayerWord(gameWord: GameWord(word: word, score: 0, unique: null), gridItems: []), switched: switched);
                }
              },
            ),
          );
        },
      );
    } else {
      return Container(
        height: 24,
        child: Text(
          'Waiting...',
        ),
      );
    }
  }
}
