import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/common_widgets/word_cubes.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:flutter/material.dart';

class CurrentWord extends StatelessWidget {
  final List<GridItem> swipedGridItems;
  final String currentWord;

  CurrentWord({this.swipedGridItems = const [], this.currentWord = ""});

  String _getWord() {
    String word = "";
    if (currentWord != null) {
      word = currentWord;
    } else {
      for (GridItem gridItem in swipedGridItems) {
        if (word != null) {
          word += gridItem.letter;
        }
      }
    }

    return word;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    debugPrint('screen size: ${mediaQuery.size}');
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
      final width = (viewportConstraints.maxWidth - (kFLUGGLE_BOARD_BORDER_WIDTH * 2));
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 0,
        ),
/*        decoration: BoxDecoration(
          border: Border.all(
            color: kFluggleBoardBorderColor,
            width: kFLUGGLE_BOARD_BORDER_WIDTH,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),*/
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: WordCubes(word: _getWord(), width: width),
            ),
          ],
        ),
      );
    });
  }
}
