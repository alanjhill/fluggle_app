import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:flutter/material.dart';

class GameBottomPanel extends StatefulWidget {
  GameBottomPanel({this.gameStarted = false, required this.startButtonPressed, required this.height});
  final bool gameStarted;
  final Function startButtonPressed;
  final double height;

  @override
  _GameBottomPanelState createState() => _GameBottomPanelState();
}

class _GameBottomPanelState extends State<GameBottomPanel> {
  bool buttonClicked = false;

  void _buttonPressed() {
    widget.startButtonPressed();
    setState(() {
      buttonClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !widget.gameStarted && !buttonClicked
        ? Expanded(
            child: Container(
              height: widget.height,
              child: Center(
                child: ButtonTheme(
                  child: CustomRaisedButton(
                    child: Text('Start'),
                    onPressed: () => _buttonPressed(),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }
}
