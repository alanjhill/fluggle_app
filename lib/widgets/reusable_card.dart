import 'package:fluggle_app/constants.dart';
import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Widget cardChild;
  final Key key;

  ReusableCard({required this.cardChild, required this.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      key: ValueKey(key),
      color: kFluggleBoardBackgroundColor,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: cardChild,
      ),
    );
  }
}
