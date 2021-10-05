import 'package:flutter/material.dart';

class ScrollUtils {
  static void scrollEndNotification({
    required ScrollMetrics scrollMetrics,
    required double width,
    required int itemCount,
    required ScrollController scrollController,
  }) async {
    await Future.delayed(const Duration(milliseconds: 0), () {
      if (scrollMetrics.axisDirection == AxisDirection.left ||
          scrollMetrics.axisDirection == AxisDirection.right) {
        if (!scrollMetrics.atEdge && !scrollMetrics.outOfRange) {
          double _position = _getNearestPosition(
              width: width,
              position: scrollMetrics.pixels,
              itemCount: itemCount);
          scrollController.animateTo(
            _position,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  static double _getNearestPosition({
    required double width,
    required double position,
    required int itemCount,
  }) {
    double newPosition = 0;

    // Iterate through the elements and find the boundaries...
    for (int counter = 0; counter < itemCount; counter++) {
      double leftBoundary = width * counter;
      double rightBoundary = width + (counter * width);

      // Find which scrolling element we are positioned in
      if (leftBoundary <= position && position <= rightBoundary) {
        if ((position - leftBoundary) <= (rightBoundary - position)) {
          newPosition = leftBoundary;
        } else if ((position - leftBoundary) > (rightBoundary - position)) {
          newPosition = rightBoundary;
        } else {
          newPosition = position;
        }
      }
    }
    return newPosition;
  }
}
