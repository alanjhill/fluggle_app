import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:flutter/material.dart';

class CurrentWord extends StatelessWidget {
  final List<GridItem> swipedGridItems;
  final String currentWord;

  CurrentWord({this.swipedGridItems, this.currentWord});

  String _getWord() {
    String word = "";
    if (currentWord != null) {
      word = currentWord;
    } else {
      for (GridItem gridItem in swipedGridItems) {
        word += gridItem.letter;
      }
    }

    return word;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
          vertical: 1,
          horizontal: 1,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: kFluggleBoardBorderColor,
            width: kFLUGGLE_BOARD_BORDER_WIDTH * 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: AutoSizeText(
                _getWord(),
              ),
            ),
          ],
        ));
  }
}
