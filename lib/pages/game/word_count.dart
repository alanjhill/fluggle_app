import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';

class WordCount extends StatelessWidget {
  const WordCount({Key? key, required this.count}) : super(key: key);
  final int count;

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Words: ${count}'),
          ],
        ),
      );
    });
  }
}
