import 'package:flutter/material.dart';

class ScrollUtils {
  static bool scrollEndNotification(
      {required ScrollMetrics scrollMetrics,
      required double width,
      required int itemCount,
      required List<ScrollController> horizontalScrollControllers,
      required int horizontalScrollerIndex}) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (scrollMetrics.axisDirection == AxisDirection.left || scrollMetrics.axisDirection == AxisDirection.right) {
        double _position = _getNearestPosition(width: width, position: scrollMetrics.pixels, itemCount: itemCount);
        horizontalScrollControllers.asMap().forEach((int index, ScrollController scrollController) {
          if (index != horizontalScrollerIndex) {
            scrollController.animateTo(_position, duration: Duration(milliseconds: 750), curve: Curves.easeInOut);
          }
        });
      }
      return true;
    });
    return false;
  }

  static double _getNearestPosition({required double width, required double position, required int itemCount}) {
    print('position: $position');
    double newPosition = 0;

    for (int counter = 0; counter < itemCount; counter++) {
      double leftBoundary = width * counter;
      double rightBoundary = width + (counter * width);

      if (leftBoundary <= position && position <= rightBoundary) {
        if ((position - leftBoundary) <= (rightBoundary - position)) {
          newPosition = leftBoundary;
        } else {
          newPosition = rightBoundary;
        }
      }
    }
    return newPosition;
  }
}
