import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:flutter/material.dart';

class GameBottomWidget extends StatelessWidget {
  final bool gameStarted;
  final Function startButtonPressed;

  GameBottomWidget({this.gameStarted = false, required this.startButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: kSTATUS_BAR_HEIGHT,
        child: Center(
          child: ButtonTheme(
            child: CustomRaisedButton(
              child: Text('Start'),
              onPressed: !gameStarted ? () => startButtonPressed() : null,
            ),
          ),
        ),
      ),
    );
  }
}
