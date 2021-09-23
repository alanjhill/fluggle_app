import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timer_controller/timer_controller.dart';

class CountdownTimer extends StatefulWidget {
  final int duration;
  final bool timerStarted;
  final bool timerPaused;
  final Function? timerEndedCallback;

  CountdownTimer({required this.duration, required this.timerStarted, required this.timerPaused, this.timerEndedCallback});

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
    _controller = TimerController.seconds(widget.duration);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(CountdownTimer oldCountdownTimer) {
    super.didUpdateWidget(oldCountdownTimer);
    if (widget.timerStarted && !oldCountdownTimer.timerStarted) {
      _controller.start();
    }

    if (widget.timerPaused && !oldCountdownTimer.timerPaused) {
      _controller.pause();
    } else if (!widget.timerPaused && oldCountdownTimer.timerPaused) {
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
