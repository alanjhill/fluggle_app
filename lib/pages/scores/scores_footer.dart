import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:flutter/material.dart';

class ScoresFooter extends StatelessWidget {
  const ScoresFooter({
    Key? key,
    required this.context,
    required this.game,
    required this.player,
    required this.height,
    required this.width,
    required this.index,
    required this.scrollController,
  }) : super(key: key);

  final BuildContext context;
  final Game game;
  final Player player;
  final double height;
  final double width;
  final int index;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(0),
      child: _buildPlayersScoresFooterContent(
        height: height,
        width: width,
        player: player,
      ),
    );
  }

  Widget _buildPlayersScoresFooterContent({
    required Player player,
    required double height,
    required double width,
  }) {
    final bool singlePlayer = game.practice;
    if (singlePlayer) {
      width = width - 4;
    } else {
      width = width / 2 - 8;
    }

    return Container(
      height: height,
      margin: const EdgeInsets.only(
          left: kScoresColumnPadding, right: kScoresColumnPadding),
      padding: const EdgeInsets.only(
          left: kScoresColumnPadding, right: kScoresColumnPadding),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _score(player: player),
            ..._wordCounts(player: player),
          ]),
    );
  }

  Widget _score({required Player player}) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const Expanded(
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
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Expanded(
              child: AutoSizeText('Total words:',
                  maxLines: 1, textAlign: TextAlign.left)),
          AutoSizeText('$wordCount', textAlign: TextAlign.right),
        ],
      ),
    );

    /// Only show the Unique Words if this is a real game
    if (game.practice == false) {
      // Unique Words
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Expanded(
                child: AutoSizeText('Unique words:',
                    maxLines: 1, textAlign: TextAlign.left)),
            AutoSizeText('$uniqueWordCount', textAlign: TextAlign.right),
          ],
        ),
      );
    }
    return rows;
  }
}
