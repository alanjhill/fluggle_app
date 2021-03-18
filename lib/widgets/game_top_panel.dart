import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/widgets/added_words_list.dart';
import 'package:fluggle_app/widgets/egg_timer.dart';
import 'package:flutter/material.dart';

class GameTopPanel extends StatefulWidget {
  bool gameStarted;
  final List<GridItem> swipedGridItems;
  final List<String> addedWords;

  GameTopPanel({@required this.gameStarted, @required this.swipedGridItems, this.addedWords});

  @override
  _GameTopPanelState createState() => _GameTopPanelState();
}

class _GameTopPanelState extends State<GameTopPanel> {
  void startEggTimer() {
    setState(() {
      //widget.gameStarted = true;
    });
  }

  void timerEnded() {
    debugPrint('timerEnded');
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    //debugPrint('screenWidth: ${screenWidth}, screenHeight: ${screenHeight}');

    return Container(
      child: Column(
        children: <Widget>[
          EggTimer(gameStarted: widget.gameStarted, timerEndedCallback: timerEnded),
          AddedWordsList(addedWords: widget.addedWords),
        ],
      ),
    );
  }
}
