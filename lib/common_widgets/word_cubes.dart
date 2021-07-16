import 'package:fluggle_app/common_widgets/letter_cube.dart';
import 'package:flutter/material.dart';

class WordCubes extends StatelessWidget {
  const WordCubes({Key? key, required this.word, required this.width}) : super(key: key);
  final String word;
  final double width;

  @override
  Widget build(BuildContext context) {
    double cubeSize = width / 8.0;
    if (word.length > 8) {
      cubeSize = width / word.length;
    }
    cubeSize -= 2.0;
    debugPrint('cubeSize: $cubeSize}');
    return Center(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        for (String letter in word.split(""))
          LetterCube(
            letter: letter,
            size: cubeSize,
          ),
      ]),
    );
  }
}
