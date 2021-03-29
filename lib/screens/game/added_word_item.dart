import 'package:flutter/material.dart';

class AddedWordItem extends StatelessWidget {
  final String? addedWord;

  const AddedWordItem({Key? key, @required this.addedWord}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(right: 10, top: 2, bottom: 2),
        child: Text(addedWord!.toUpperCase()),
      ),
    );
  }
}
