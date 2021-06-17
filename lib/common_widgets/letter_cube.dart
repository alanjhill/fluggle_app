import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/models/game_board/row_col.dart';
import 'package:fluggle_app/pages/game/grid_cell.dart';
import 'package:flutter/material.dart';

class LetterCube extends StatelessWidget {
  const LetterCube({Key? key, required this.letter, required this.size}) : super(key: key);
  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: kFluggleCubeColor,
        border: Border.all(width: 1.0, color: kFluggleCubeColor),
      ),
      child: Container(
        alignment: Alignment.center,
        color: kFluggleCubeColor,
        padding: EdgeInsets.all(0.0),
        margin: EdgeInsets.all(0.0),
        child: AutoSizeText(
          letter.toUpperCase(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: kFluggleLetterColor,
          ),
        ),
      ),
    );
  }
}
