import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:flutter/material.dart';

class SwipeLines extends StatefulWidget {
  final List<GridItem> swipedGridItems;
  final double gridSize;

  const SwipeLines({Key key, this.swipedGridItems, this.gridSize}) : super(key: key);

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
      widget.swipedGridItems.forEach((GridItem swipedGridItem) {
        double offsetX = (swipedGridItem.col * 2 + 1) * ((widget.gridSize - (kGAME_BOARD_PADDING / 2) - kFLUGGLE_BOARD_BORDER_WIDTH * 2) / 8);
        double offsetY = (swipedGridItem.row * 2 + 1) * ((widget.gridSize - (kGAME_BOARD_PADDING / 2) - kFLUGGLE_BOARD_BORDER_WIDTH * 2) / 8);
        offsets.add(Offset(offsetX, offsetY));
      });
    }

    for (int i = 0; i < offsets.length - 1; i++) {
      LinePainter linePainter = LinePainter(start: offsets[i], end: offsets[i + 1]);
      linePainters.add(
        AnimatedContainer(
          child: CustomPaint(size: Size.infinite, painter: linePainter),
          duration: Duration(milliseconds: 5000),
          curve: Curves.easeIn,
        ),
      );
    }
    debugPrint('linePainters.length: ${offsets.length}');

    return linePainters;
  }
}

class LinePainter extends CustomPainter {
  final Offset start, end;

  LinePainter({this.start, this.end});

  double _getLineWidth() {
    if (start.dx == end.dx || start.dy == end.dy) {
      return kSwipeLineWidth;
    } else {
      return kSwipeLineWidth - 1;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (start == null || end == null) return;
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
