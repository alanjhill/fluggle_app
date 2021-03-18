import 'package:fluggle_app/constants.dart';
import 'package:flutter/material.dart';

class GameBoardBottomBar extends StatelessWidget {
  final bool gameStarted;
  final Function startButtonPressed;

  GameBoardBottomBar({this.gameStarted, this.startButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: kSTATUS_BAR_HEIGHT,
        child: Center(
          child: ButtonTheme(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: KFlugglePrimaryColor,
                //padding: EdgeInsets.all(10.0),
              ),
              child: Text('Start'),
              onPressed: gameStarted ? null : startButtonPressed,
            ),
          ),
        ),
      ),
    );
  }
}
