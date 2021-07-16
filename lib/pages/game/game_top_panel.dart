import 'dart:collection';

import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/pages/game/current_word.dart';
import 'package:fluggle_app/pages/game/word_count.dart';
import 'package:flutter/material.dart';

class GameTopPanel extends StatefulWidget {
  final bool gameStarted;
  final List<GridItem> swipedGridItems;
  final String currentWord;
  final LinkedHashMap<String, PlayerWord>? addedWords;

  GameTopPanel({
    this.gameStarted = false,
    this.swipedGridItems = const [],
    this.currentWord = "",
    this.addedWords,
  });

  @override
  _GameTopPanelState createState() => _GameTopPanelState();
}

class _GameTopPanelState extends State<GameTopPanel> {
  void startEggTimer() {
    setState(() {
      //widget.gameStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final MediaQueryData mediaQuery = MediaQuery.of(context);
    //final screenWidth = mediaQuery.size.width;
    //final screenHeight = mediaQuery.size.height;
    //debugPrint('screenWidth: ${screenWidth}, screenHeight: ${screenHeight}');
    //debugPrint('context size: ${context.size}');
    //RenderBox rb = context.findRenderObject() as RenderBox;
    //debugPrint('rb: ${rb?.size ?? Size.zero}');
    //final height = rb.size.height;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: kGameBoardPadding / 2, vertical: kGameBoardPadding / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
                child: WordCount(
              count: widget.addedWords!.length,
            )),
            SizedBox(height: kGameBoardPadding / 2),
            Expanded(
              child: CurrentWord(
                swipedGridItems: widget.swipedGridItems,
                currentWord: widget.currentWord,
              ),
            ),
          ],
        ),
      );
    });
  }

  void timerEnded() {
    debugPrint('timerEnded');
  }
}
