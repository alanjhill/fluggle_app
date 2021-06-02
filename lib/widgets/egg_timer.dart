import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_countdown_timer/index.dart';

class EggTimer extends StatefulWidget {
  final bool? gameStarted;
  final Function? timerEndedCallback;

  EggTimer({this.gameStarted, this.timerEndedCallback});

  @override
  _EggTimerState createState() => _EggTimerState();
}

class _EggTimerState extends State<EggTimer> {
  CountdownTimerController? controller;
  int? endTime;

  void onEnd() {
    debugPrint('ended');
    widget.timerEndedCallback!();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(EggTimer oldEggTimer) {
    super.didUpdateWidget(oldEggTimer);
    if (widget.gameStarted! && !oldEggTimer.gameStarted!) {
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * kGAME_TIME;
      controller = CountdownTimerController(endTime: endTime!, onEnd: onEnd);
      controller!.start();
    } else if (!widget.gameStarted! && oldEggTimer.gameStarted!) {
      if (controller != null) {
        controller?.disposeTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (endTime != null && controller != null) {
      return CountdownTimer(
        controller: controller,
        onEnd: onEnd,
        endTime: endTime,
        widgetBuilder: (_, CurrentRemainingTime? time) {
          if (time == null) {
            time = CurrentRemainingTime(sec: kGAME_TIME);
          }
          return Text(
            '${time.min != null ? time.min.toString().padLeft(1, "0") : "0"}:${time.sec.toString().padLeft(2, "0")}',
            style: kEggTimerTextStyle,
          );
        },
      );
    } else {
      CurrentRemainingTime time = CurrentRemainingTime(sec: kGAME_TIME);
      return Text(
        '${time.min != null ? time.min.toString().padLeft(1, "0") : "0"}:${time.sec.toString().padLeft(2, "0")}',
        style: kEggTimerTextStyle,
      );
    }
  }
}
