import 'package:flutter/material.dart';

class ReusableCard extends StatelessWidget {
  final Widget cardChild;
  final double padding;

  const ReusableCard({
    Key? key,
    required this.cardChild,
    this.padding = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(key),
      shape: const RoundedRectangleBorder(
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
