import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:flutter/material.dart';

class GameBottomPanel extends StatefulWidget {
  GameBottomPanel({this.gameStarted = false, this.gamePaused = false, required this.startButtonPressed, required this.pauseButtonPressed, required this.height});
  final bool gameStarted;
  final bool gamePaused;
  final Function startButtonPressed;
  final Function pauseButtonPressed;
  final double height;

  @override
  _GameBottomPanelState createState() => _GameBottomPanelState();
}

class _GameBottomPanelState extends State<GameBottomPanel> {
  bool buttonClicked = false;

  void _buttonPressed(BuildContext context) {
    if (!widget.gameStarted) {
      debugPrint('>>> START BUTTON');
      widget.startButtonPressed();
    } else {
      debugPrint('>>> PAUSE BUTTON');
      widget.pauseButtonPressed(context);
    }
    setState(() {
      buttonClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: widget.height,
        child: Center(
          child: ButtonTheme(
            child: CustomRaisedButton(
              child: !widget.gameStarted ? Text('Start') : Text('Pause'),
              onPressed: () => _buttonPressed(context),
            ),
          ),
        ),
      ),
    );
  }
}
