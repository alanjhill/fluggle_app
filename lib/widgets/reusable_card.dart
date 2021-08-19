import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Widget cardChild;
  final Key key;
  final double padding;

  ReusableCard({
    required this.cardChild,
    required this.key,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(key),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: cardChild,
      ),
    );
  }
}
