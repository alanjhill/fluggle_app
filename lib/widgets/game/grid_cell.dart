import 'package:fluggle_app/models/row_col.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GridCell extends SingleChildRenderObjectWidget {
  final RowCol rowCol;
  final String letter;
  final bool swiped;

  GridCell({
    Widget child,
    Key key,
    this.rowCol,
    this.letter,
    this.swiped,
  }) : super(child: child, key: key);

  @override
  GridCellRenderObject createRenderObject(BuildContext context) => GridCellRenderObject()
    ..rowCol = rowCol
    ..letter = letter;

  @override
  void updateRenderObject(BuildContext context, GridCellRenderObject renderObject) {
    renderObject.rowCol = rowCol;
    renderObject.letter = letter;
  }
}

class GridCellRenderObject extends RenderProxyBox {
  RowCol rowCol;
  String letter;
}
