import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/game/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameBottomPanel extends ConsumerStatefulWidget {
  GameBottomPanel({required this.startButtonPressed, required this.pauseButtonPressed, required this.height});
  final Function startButtonPressed;
  final Function pauseButtonPressed;
  final double height;

  @override
  _GameBottomPanelState createState() => _GameBottomPanelState();
}

class _GameBottomPanelState extends ConsumerState<GameBottomPanel> {
  bool buttonClicked = false;

  void _buttonPressed(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    if (!gameState.gameStarted) {
      widget.startButtonPressed(context, ref);
    } else {
      widget.pauseButtonPressed(context, ref);
    }
    setState(() {
      buttonClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.read(gameStateProvider);
    return Expanded(
      child: Container(
        height: widget.height,
        child: Center(
          child: ButtonTheme(
            child: CustomRaisedButton(
              child: !gameState.gameStarted ? Text('Start') : Text('Pause'),
              onPressed: () => _buttonPressed(context, ref),
            ),
          ),
        ),
      ),
    );
  }
}
