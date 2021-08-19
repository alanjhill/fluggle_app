import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/models/game_board/row_col.dart';
import 'package:fluggle_app/pages/game/grid_cell.dart';
import 'package:flutter/material.dart';

class GameCube extends StatefulWidget {
  final RowCol rowCol;
  final List<List<GridItem>> gridItems;
  final String letter;

  const GameCube({required this.rowCol, required this.letter, required this.gridItems});

  @override
  _GameCubeState createState() => _GameCubeState();
}

class _GameCubeState extends State<GameCube> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedContainer(
        padding: EdgeInsets.all(
          _getPadding(
            widget.rowCol.row,
            widget.rowCol.col,
          ),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: kFluggleCubeColor,
            ),
            child: _buildGameCube(
              widget.rowCol,
            ),
          ),
        ),
        duration: Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      ),
    );
  }

  double _getPadding(int y, int x) {
    GridItem gridItem = widget.gridItems[y][x];
    return gridItem.swiped ? kCubeSelectedPadding : kCubePadding;
  }

  Widget _buildGameCube(RowCol rowCol) {
    GridItem gridItem = widget.gridItems[rowCol.row][rowCol.col];

    debugPrint('>>> building game cube >>>');
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(kLetterPadding),
      child: GridCell(
        child: Container(
          alignment: Alignment.center,
          color: kFluggleCubeColor,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            child: AutoSizeText(
              widget.letter,
              key: ValueKey(widget.letter),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: gridItem.swiped ? kFluggleLetterHighlightColor : kFluggleLetterColor,
              ),
            ),
          ),
        ),
        rowCol: rowCol,
        letter: widget.letter,
      ),
    );
  }
}
