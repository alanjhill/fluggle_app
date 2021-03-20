import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/widgets/game/added_words_list.dart';
import 'package:fluggle_app/widgets/game/current_word.dart';
import 'package:fluggle_app/widgets/egg_timer.dart';
import 'package:flutter/material.dart';

class GameTopWidget extends StatefulWidget {
  final bool gameStarted;
  final List<GridItem> swipedGridItems;
  final List<String> addedWords;
  final String currentWord;

  GameTopWidget({@required this.gameStarted, @required this.swipedGridItems, this.addedWords, this.currentWord});

  @override
  _GameTopWidgetState createState() => _GameTopWidgetState();
}

class _GameTopWidgetState extends State<GameTopWidget> {
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: kGAME_BOARD_PADDING / 2, vertical: kGAME_BOARD_PADDING / 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          //EggTimer(gameStarted: widget.gameStarted, timerEndedCallback: timerEnded),
          Expanded(
            child: AddedWordsList(
              addedWords: widget.addedWords,
            ),
          ),
          SizedBox(height: kGAME_BOARD_PADDING / 2),
          Expanded(
            child: CurrentWord(
              swipedGridItems: widget.swipedGridItems,
              currentWord: widget.currentWord,
            ),
          ),
        ],
      ),
    );
  }

  void timerEnded() {
    debugPrint('timerEnded');
  }
}