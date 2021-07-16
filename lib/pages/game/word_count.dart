import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class WordCount extends StatelessWidget {
  const WordCount({Key? key, required this.count}) : super(key: key);
  final int count;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    debugPrint('screen size: ${mediaQuery.size}');
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            count > 0
                ? Text(
                    'WORDS: ',
                    maxLines: 1,
                    style: TextStyle(fontSize: 36),
                  )
                : Text(''),
            count > 0
                ? Container(
                    width: 48,
                    child: AutoSizeText(
                      '$count',
                      maxLines: 1,
                      style: TextStyle(fontSize: 36),
                    ),
                  )
                : Text(''),
          ],
        ),
      );
    });
  }
}
