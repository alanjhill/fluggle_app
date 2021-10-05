import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';

class LetterCube extends StatelessWidget {
  const LetterCube(
      {Key? key,
      required this.letter,
      required this.size,
      this.textColor = kFluggleLetterColor,
      this.cubeColor = kFluggleCubeColor})
      : super(key: key);
  final String letter;
  final double size;
  final Color textColor;
  final Color cubeColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      color: Colors.transparent,
      elevation: 4,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: kFluggleCubeColor,
          //border: Border.all(width: 1.0, color: kFluggleCubeColor),
        ),
        child: Container(
          color: cubeColor,
          padding: const EdgeInsets.only(top: 2.0),
          margin: const EdgeInsets.all(0.0),
          child: AutoSizeText(
            letter.toUpperCase(),
            maxLines: 1,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: textColor,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ),
      ),
    );
  }
}
