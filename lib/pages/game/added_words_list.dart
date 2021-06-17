import 'dart:collection';

import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/pages/game/added_word_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddedWordsList extends StatefulWidget {
  final LinkedHashMap<String, PlayerWord>? addedWords;

  AddedWordsList({this.addedWords});

  @override
  _AddedWordsListState createState() => _AddedWordsListState();
}

class _AddedWordsListState extends State<AddedWordsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients && _scrollController.position != null) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 150), curve: Curves.easeIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      debugPrint('callback');
      _scrollToTop();
    });

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: kFluggleBoardBorderColor,
          width: kFLUGGLE_BOARD_BORDER_WIDTH,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[_getThing()],
      ),
    );
  }

  _getThing() {
    return widget.addedWords!.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return Column(
              children: <Widget>[
                Text(''),
              ],
            );
          })
        : Expanded(
            child: Center(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                controller: _scrollController,
                itemBuilder: (ctx, index) {
                  String word = widget.addedWords!.keys.toList()[index];
                  return AddedWordItem(addedWord: widget.addedWords![word]);
                },
                itemCount: widget.addedWords!.length,
                reverse: false,
              ),
            ),
          );
  }
}
