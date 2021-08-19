import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/pages/scores/scores_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Scores extends StatelessWidget {
  Scores({
    required this.context,
    required this.game,
    required this.player,
    required this.wordTally,
    required this.height,
    required this.width,
    required this.verticalScrollController,
    required this.index,
    required this.first,
  });

  final BuildContext context;
  final Game game;
  final Player player;
  final Map<String, int> wordTally;
  final double height;
  final double width;
  final ScrollController verticalScrollController;
  final int index;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildPlayersScoresContent(
            game: game,
            player: player,
            height: height,
            width: width,
            wordTally: wordTally,
            first: first,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersScoresContent({
    required Game game,
    required Player player,
    required Map<String, int> wordTally,
    required double height,
    required double width,
    required bool first,
  }) {
    final bool showScrollbar = !first || game.practice == true;
    return Container(
      height: height,
      width: width,
      child: Container(
        height: height,
        width: width,
        margin: EdgeInsets.only(left: kScoresColumnPadding, right: kScoresColumnPadding, bottom: kScoresColumnPadding),
        padding: EdgeInsets.only(left: 0.0, right: 0.0, bottom: kScoresColumnPadding),
        decoration: BoxDecoration(
          color: kFluggleDarkColor,
          border: Border.all(width: 1.0, color: Colors.white),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: _buildPlayerScoresList(
          context,
          game: game,
          player: player,
          wordTally: wordTally,
          switched: first == true ? false : true,
          scrollController: verticalScrollController,
          showScrollbar: showScrollbar,
          first: first,
        ),
      ),
    );
  }

  Widget _buildPlayerScoresList(
    BuildContext context, {
    required Game game,
    required Map<String, int> wordTally,
    required bool switched,
    required ScrollController scrollController,
    required bool first,
    required Player player,
    required bool showScrollbar,
  }) {
    final PlayerStatus playerStatus = game.playerUids[player.playerId] as PlayerStatus;

    switch (playerStatus) {
      case PlayerStatus.invited:
      case PlayerStatus.accepted:
        return Text('Waiting...');
      case PlayerStatus.finished:
        return _playerFinished(showScrollbar: showScrollbar, switched: switched);
      case PlayerStatus.declined:
        return Text('Declined');
      case PlayerStatus.resigned:
        return Text('Resigned');
    }
  }

  Widget _playerFinished({required bool showScrollbar, required bool switched}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          child: RawScrollbar(
            controller: verticalScrollController,
            thumbColor: Colors.white,
            radius: Radius.circular(8.0),
            thickness: showScrollbar ? 8.0 : 0.0,
            isAlwaysShown: true,
            interactive: true,
            child: ListView.builder(
              controller: verticalScrollController,
              padding: EdgeInsets.only(right: 16.0),
              itemCount: wordTally.length,
              itemBuilder: (context, index) {
                String word = wordTally.keys.elementAt(index);
                if (player.words![word] != null) {
                  return ScoresItem(playerWord: player.words![word]!, switched: switched);
                } else {
                  return ScoresItem(
                      playerWord: PlayerWord(
                          gameWord: GameWord(
                            word: word,
                            score: 0,
                            unique: null,
                          ),
                          gridItems: []),
                      switched: switched);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
