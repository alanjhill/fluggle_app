import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/models/row_col.dart';
import 'package:fluggle_app/widgets/grid_cell.dart';
import 'package:fluggle_app/widgets/letter_cube.dart';
import 'package:flutter/material.dart';

class GridItemWidget extends StatefulWidget {
  final RowCol rowCol;
  final List<List<GridItem>> gridItems;
  final List<String> letters;

  GridItemWidget({this.gridItems, this.letters, this.rowCol});

  @override
  _GridItemWidgetState createState() => _GridItemWidgetState();
}

class _GridItemWidgetState extends State<GridItemWidget> {
  GlobalKey gridItemKey;

  @override
  void initState() {
    gridItemKey = new GlobalKey(debugLabel: 'Grid Item: ${widget.rowCol}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedContainer(
        padding: EdgeInsets.all(_getPadding(widget.rowCol.row, widget.rowCol.col)),
        child: GridTile(
          key: widget.key,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: kFluggleCubeColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: GridTile(
              child: _buildGridItem(
                widget.rowCol,
              ),
            ),
          ),
        ),
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      ),
    );
  }

  double _getPadding(int y, int x) {
    GridItem gridItem = widget.gridItems[y][x];
    double padding = kGAME_BOARD_PADDING;
    if (gridItem.swiped) {
      padding = kCUBE_SELECTED_PADDING;
    } else {
      padding = kCUBE_PADDING;
    }

    return padding;
  }

  Widget _buildGridItem(RowCol rowCol) {
    GridItem gridItem = widget.gridItems[rowCol.row][rowCol.col];

    return Padding(
      padding: EdgeInsets.all(kLETTER_PADDING),
      child: GridCell(
        child: LetterCube(
          row: rowCol.row,
          col: rowCol.col,
          letter: widget.letters[rowCol.col + (kGridCount * rowCol.row)],
          swiped: gridItem.swiped,
        ),
        rowCol: rowCol,
        letter: widget.letters[rowCol.col + (kGridCount * rowCol.row)],
        swiped: false,
      ),
    );
  }
}
