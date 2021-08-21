import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game_state.dart';
import 'package:fluggle_app/pages/game/current_word.dart';
import 'package:fluggle_app/pages/game/word_count.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameTopPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: kGameBoardPadding / 2, vertical: kGameBoardPadding / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
                child: WordCount(
              count: gameState.addedWords.length,
            )),
            SizedBox(height: kGameBoardPadding / 2),
            Expanded(
              child: CurrentWord(
                swipedGridItems: gameState.swipedGridItems,
                currentWord: gameState.currentWord,
                currentWordStatus: gameState.currentWordStatus,
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
