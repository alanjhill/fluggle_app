import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:flutter/material.dart';

class ScoresItem extends StatefulWidget {
  final PlayerWord playerWord;

  ScoresItem({required this.playerWord});

  @override
  _ScoresItemState createState() => _ScoresItemState();
}

class _ScoresItemState extends State<ScoresItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 2.0, right: 2.0),
      padding: EdgeInsets.only(left: 2.0, right: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: _getWordText(playerWord: widget.playerWord),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: _getWordScore(playerWord: widget.playerWord),
            ),
          ),
        ],
      ),
    );
  }

  Text _getWordText({required PlayerWord playerWord}) {
    if (playerWord.gameWord.unique == true) {
      return Text(
        '${playerWord.gameWord.word}',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: kFluggleSecondaryColor,
        ),
      );
    } else if (playerWord.gameWord.unique == false) {
      return Text(
        '${playerWord.gameWord.word}',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.lineThrough,
          color: Colors.white,
        ),
      );
    } else {
      return Text(
        '${playerWord.gameWord.word}',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.blueGrey,
          fontWeight: FontWeight.w500,
        ),
      );
    }
  }

  Text _getWordScore({required PlayerWord playerWord}) {
    if (playerWord.gameWord.unique == true) {
      return Text(
        '${widget.playerWord.gameWord.score}',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: kFluggleSecondaryColor,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (playerWord.gameWord.unique == false) {
      return Text(
        '${widget.playerWord.gameWord.score}',
        textAlign: TextAlign.right,
      );
    } else {
      return Text(
        '-',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Colors.grey,
        ),
      );
    }
  }
}
