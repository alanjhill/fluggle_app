import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/models/row_col.dart';
import 'package:fluggle_app/screens/game/grid_cell.dart';
import 'package:flutter/material.dart';

class GameCubeWidget extends StatefulWidget {
  final RowCol rowCol;
  final List<List<GridItem>> gridItems;
  final String letter;

  GameCubeWidget({required this.rowCol, this.letter = "", this.gridItems = const []});

  @override
  _GameCubeWidgetState createState() => _GameCubeWidgetState();
}

class _GameCubeWidgetState extends State<GameCubeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedContainer(
        padding: EdgeInsets.all(_getPadding(widget.rowCol.row, widget.rowCol.col)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            color: kFluggleCubeColor,
          ),
          child: _buildGameCube(
            widget.rowCol,
          ),
        ),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      ),
    );
  }

  double _getPadding(int y, int x) {
    GridItem gridItem = widget.gridItems[y][x];
    return gridItem.swiped ? kCUBE_SELECTED_PADDING : kCUBE_PADDING;
  }

  Widget _buildGameCube(RowCol rowCol) {
    GridItem gridItem = widget.gridItems[rowCol.row][rowCol.col];

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(kLETTER_PADDING),
      child: GridCell(
        child: Container(
          alignment: Alignment.center,
          color: kFluggleCubeColor,
          child: AutoSizeText(
            widget.letter,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: gridItem.swiped ? kFluggleLetterHighlightColor : kFluggleLetterColor,
            ),
          ),
        ),
        rowCol: rowCol,
        letter: widget.letter,
      ),
    );
  }
}
