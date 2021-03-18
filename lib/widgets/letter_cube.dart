import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants.dart';
import 'package:flutter/material.dart';

class LetterCube extends StatefulWidget {
  final int row;
  final int col;
  final String letter;
  final bool swiped;

  LetterCube({this.row, this.col, this.letter, this.swiped = false});

  @override
  _LetterCubeState createState() => _LetterCubeState();
}

class _LetterCubeState extends State<LetterCube> {
  @override
  Widget build(BuildContext context) {
    //debugPrint("LetterCube.build, swiped: ${widget.swiped}");
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      alignment: Alignment.center,
      color: kFluggleCubeColor,
      child: AutoSizeText(
        widget.letter,
        style: TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.bold,
          color: widget.swiped ? kFluggleLetterHighlightColor : kFluggleLetterColor,
        ),
      ),
    );
  }
}
