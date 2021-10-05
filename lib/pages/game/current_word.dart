import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game_state.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/widgets/word_cubes.dart';
import 'package:flutter/material.dart';

class CurrentWord extends StatelessWidget {
  final List<GridItem> swipedGridItems;
  final String? currentWord;
  final WordStatus currentWordStatus;

  const CurrentWord(
      {Key? key,
      this.swipedGridItems = const [],
      this.currentWord,
      required this.currentWordStatus})
      : super(key: key);

  String _getWord() {
    String? word;
    if (currentWord != null) {
      word = currentWord;
    } else {
      for (GridItem gridItem in swipedGridItems) {
        if (word != null) {
          word += gridItem.letter;
        }
      }
    }
    return word!;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    debugPrint('screen size: ${mediaQuery.size}');
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        final width =
            (viewportConstraints.maxWidth - (kFluggleBoardBorderWidth * 2));
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                WordCubes(
                    word: _getWord(),
                    width: width,
                    spacing: kCurrentWordCubeSpacing,
                    wordStatus: currentWordStatus),
                //Text('$currentWordStatus'),
                //WordFeedback(word: _getWord(), width: width, spacing: kCurrentWordCubeSpacing),
              ],
            ),
          ],
        );
      },
    );
  }
}
