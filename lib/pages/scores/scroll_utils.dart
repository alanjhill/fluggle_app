import 'package:flutter/material.dart';

class ScrollUtils {
  static bool scrollEndNotification(
      {required ScrollMetrics scrollMetrics,
      required double width,
      required List<ScrollController> horizontalScrollControllers,
      required int horizontalScrollerIndex}) {
    print('>>> _scrollEndNotification, axisDirection: ${scrollMetrics.axisDirection}');
    Future.delayed(Duration(milliseconds: 0), () {
      if (scrollMetrics.axisDirection == AxisDirection.left || scrollMetrics.axisDirection == AxisDirection.right) {
        double _position = _getNearestPosition(width: width, position: scrollMetrics.pixels);
        horizontalScrollControllers.asMap().forEach((int index, ScrollController scrollController) {
          if (index != horizontalScrollerIndex) {
            scrollController.animateTo(_position, duration: Duration(milliseconds: 1000), curve: Curves.decelerate);
          }
        });
      }
      return true;
    });
    return false;
  }

  static double _getNearestPosition({required double width, required double position}) {
    print('(width / 2) - position: ${(width / 2) - position}, position: ${position}');
    if ((width / 2) - position > position) {
      return 0;
    } else {
      return (width / 2);
    }
  }
}
