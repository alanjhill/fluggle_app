import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/game/added_word_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AddedWordsList extends StatefulWidget {
  final List<String>? addedWords;

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
      // padding: EdgeInsets.symmetric(
      //   vertical: 5,
      //   horizontal: 50,
      // ),
      decoration: BoxDecoration(
        border: Border.all(
          color: kFluggleBoardBorderColor,
          width: kFLUGGLE_BOARD_BORDER_WIDTH * 2,
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
                  return AddedWordItem(addedWord: widget.addedWords![index]);
                },
                itemCount: widget.addedWords!.length,
                reverse: false,
              ),
            ),
          );
  }
}
