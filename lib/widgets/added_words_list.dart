import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/widgets/added_word_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AddedWordsList extends StatefulWidget {
  final List<String> addedWords;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('callback');
      _scrollToTop();
    });
    return widget.addedWords.isEmpty
        ? LayoutBuilder(builder: (ctx, constraints) {
            return Column(
              children: <Widget>[
                Text('Start finding words...'),
              ],
            );
          })
        : Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: kGAME_BOARD_PADDING) / 2,
              color: Colors.red,
              //width: 150,
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                controller: _scrollController,
                itemBuilder: (ctx, index) {
                  return AddedWordItem(addedWord: widget.addedWords[index]);
                },
                itemCount: widget.addedWords.length,
                reverse: false,
              ),
            ),
          );
  }
}
