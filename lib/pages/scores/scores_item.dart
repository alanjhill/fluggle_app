import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:flutter/material.dart';

class ScoresItem extends StatefulWidget {
  final PlayerWord playerWord;
  final bool switched;

  const ScoresItem({Key? key, required this.playerWord, this.switched = false}) : super(key: key);

  @override
  _ScoresItemState createState() => _ScoresItemState();
}

class _ScoresItemState extends State<ScoresItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 2.0, right: 2.0),
      padding: const EdgeInsets.only(left: 2.0, right: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ..._getScoreLine(playerWord: widget.playerWord, switched: widget.switched),
        ],
      ),
    );
  }

  List<Widget> _getScoreLine({required PlayerWord playerWord, bool switched = false}) {
    List<Widget> widgets = [];
    widgets.add(
      Expanded(
        flex: 3,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: _getWordText(playerWord: widget.playerWord, textAlign: switched ? TextAlign.right : TextAlign.left),
        ),
      ),
    );
    widgets.add(
      Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: _getWordScore(playerWord: widget.playerWord, textAlign: switched ? TextAlign.left : TextAlign.right),
        ),
      ),
    );

    if (switched) {
      return List.from(widgets.reversed);
    } else {
      return widgets;
    }
  }

  AutoSizeText _getWordText({required PlayerWord playerWord, required TextAlign textAlign}) {
    if (playerWord.gameWord.unique == true) {
      return AutoSizeText(
        playerWord.gameWord.word,
        wrapWords: false,
        textAlign: textAlign,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: kFluggleLightColor,
        ),
      );
    } else if (playerWord.gameWord.unique == false) {
      return AutoSizeText(
        playerWord.gameWord.word,
        wrapWords: false,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: kFluggleLightColor.withAlpha(128),
        ),
      );
    } else {
      return AutoSizeText(
        playerWord.gameWord.word,
        wrapWords: false,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.lineThrough,
          color: Colors.grey[500],
        ),
      );
    }
  }

  Text _getWordScore({required PlayerWord playerWord, required TextAlign textAlign}) {
    if (playerWord.gameWord.unique == true) {
      return Text(
        '${widget.playerWord.gameWord.score}',
        textAlign: textAlign,
        style: const TextStyle(
          color: kFluggleLightColor,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (playerWord.gameWord.unique == false) {
      return Text(
        '${widget.playerWord.gameWord.score}',
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: kFluggleLightColor.withAlpha(128),
        ),
      );
    } else {
      return Text(
        '-',
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.lineThrough,
          color: Colors.grey[500],
        ),
      );
    }
  }
}
