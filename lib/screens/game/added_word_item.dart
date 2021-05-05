import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:flutter/material.dart';

class AddedWordItem extends StatelessWidget {
  final PlayerWord? addedWord;

  const AddedWordItem({Key? key, @required this.addedWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(right: 10, top: 2, bottom: 2),
        child: Text(addedWord!.gameWord.word.toUpperCase()),
      ),
    );
  }
}
