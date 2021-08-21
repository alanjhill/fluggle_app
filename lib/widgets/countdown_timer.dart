import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timer_controller/timer_controller.dart';

class CountdownTimer extends StatefulWidget {
  final bool gameStarted;
  final bool gamePaused;
  final int gameTime;
  final Function? timerEndedCallback;

  CountdownTimer({required this.gameStarted, required this.gameTime, this.timerEndedCallback, this.gamePaused = false});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late TimerController _controller;

  void timerEnded() {
    widget.timerEndedCallback!();
  }

  @override
  void initState() {
    super.initState();
    _controller = TimerController.seconds(widget.gameTime);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(CountdownTimer oldCountdownTimer) {
    super.didUpdateWidget(oldCountdownTimer);
    if (widget.gameStarted && !oldCountdownTimer.gameStarted) {
      _controller.start();
    }

    if (widget.gamePaused && !oldCountdownTimer.gamePaused) {
      _controller.pause();
    } else if (!widget.gamePaused && oldCountdownTimer.gamePaused) {
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TimerControllerListener(
      controller: _controller,
      listenWhen: (previousValue, currentValue) => previousValue.status != currentValue.status,
      listener: (context, timerValue) {
        debugPrint('Remaining: ${timerValue.remaining}');
        if (timerValue.remaining == 0) {
          timerEnded();
        }
      },
      child: TimerControllerBuilder(
        controller: _controller,
        builder: (context, timerValue, _) {
/*          Color timerColor = Colors.black;
          switch (timerValue.status) {
            case TimerStatus.initial:
              timerColor = Colors.black;
              break;
            case TimerStatus.running:
              timerColor = Colors.green;
              break;
            case TimerStatus.paused:
              timerColor = Colors.grey;

              break;
            case TimerStatus.finished:
              timerColor = Colors.red;
              break;
          }*/
          var minutes = timerValue.remaining / 60;
          var seconds = timerValue.remaining % 60;
          return Text(
            '${minutes.toInt().toString().padLeft(1, "0")}:${seconds.toString().padLeft(2, "0")}',
            style: kTimerTextStyle,
          );
        },
      ),
    );
  }
}
