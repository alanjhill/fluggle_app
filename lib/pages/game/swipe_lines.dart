import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:flutter/material.dart';

class SwipeLines extends StatefulWidget {
  final List<GridItem> swipedGridItems;
  final double gridSize;

  const SwipeLines(
      {Key? key, this.swipedGridItems = const [], this.gridSize = 0})
      : super(key: key);

  @override
  createState() => _SwipeLinesState();
}

class _SwipeLinesState extends State<SwipeLines> {
  @override
  build(_) => Stack(children: getLinePainters());

  getLinePainters() {
    List<Widget> linePainters = [];

    List<Offset> offsets = [];

    if (widget.swipedGridItems.length > 1) {
      for (var swipedGridItem in widget.swipedGridItems) {
        double offsetX = (swipedGridItem.col * 2 + 1) *
            ((widget.gridSize -
                    (kGameBoardPadding / 2) -
                    kFluggleBoardBorderWidth * 2) /
                8);
        double offsetY = (swipedGridItem.row * 2 + 1) *
            ((widget.gridSize -
                    (kGameBoardPadding / 2) -
                    kFluggleBoardBorderWidth * 2) /
                8);
        offsets.add(Offset(offsetX, offsetY));
      }
    }

    for (int i = 0; i < offsets.length - 1; i++) {
      LinePainter linePainter =
          LinePainter(start: offsets[i], end: offsets[i + 1]);
      linePainters.add(
        AnimatedContainer(
          child: CustomPaint(size: Size.infinite, painter: linePainter),
          duration: const Duration(milliseconds: 5000),
          curve: Curves.easeIn,
        ),
      );
    }
    debugPrint('linePainters.length: ${offsets.length}');

    return linePainters;
  }
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter({this.start = const Offset(0, 0), this.end = const Offset(0, 0)});

  double _getLineWidth() {
    if (start.dx == end.dx || start.dy == end.dy) {
      return kSwipeLineWidth;
    } else {
      return kSwipeLineWidth - 1;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //if (start == null || end == null) return;
    canvas.drawLine(
      start,
      end,
      Paint()
        ..strokeWidth = _getLineWidth()
        ..color = kFluggleSwipeLineColor,
    );
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}
