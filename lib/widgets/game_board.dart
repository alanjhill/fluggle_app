import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/models/row_col.dart';
import 'package:fluggle_app/widgets/grid_cell.dart';
import 'package:fluggle_app/widgets/grid_item_widget.dart';
import 'package:fluggle_app/widgets/letter_cube.dart';
import 'package:fluggle_app/widgets/swipe_lines.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GameBoard extends StatefulWidget {
  final bool gameStarted;
  final List<String> letters;
  final List<List<GridItem>> gridItems;
  final List<String> addedWords;

  final Function addSwipedGridItem;
  final Function isSwipedGridItem;
  final Function getSwipedGridItems;
  final Function resetSwipedItems;
  final Function addWord;

  GameBoard({
    this.gameStarted,
    this.letters,
    this.gridItems,
    this.addedWords,
    this.addSwipedGridItem,
    this.isSwipedGridItem,
    this.getSwipedGridItems,
    this.resetSwipedItems,
    this.addWord,
  });

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  GlobalKey gridKey = new GlobalKey();
  GridItem currentGridItem;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    print('kToolbarHeight: ${kToolbarHeight}');

    double gridSize = mediaQuery.size.width - kGAME_BOARD_PADDING / 2;

    return Container(
      margin: EdgeInsets.all(kGAME_BOARD_PADDING / 2),
      decoration: BoxDecoration(
        color: kFluggleBoardBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: kFluggleBoardColor,
          width: kFLUGGLE_BOARD_BORDER_WIDTH,
        ),
      ),
      child: Listener(
        child: Container(
          //decoration: BoxDecoration(border: Border.all(width: 5), borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: <Widget>[
              // Grid lines
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: kGridCount,
                ),
                itemBuilder: _buildGridLines,
                itemCount: kGridCount * kGridCount,
                physics: const NeverScrollableScrollPhysics(),
              ),
              // Swipe lines
              SwipeLines(swipedGridItems: widget.getSwipedGridItems(), gridSize: gridSize),
              // Grid Cells / Items
              GridView.builder(
                key: gridKey,
                shrinkWrap: false,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: kGridCount,
                ),
                itemBuilder: _buildGridItems,
                itemCount: kGridCount * kGridCount,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        ),
        onPointerDown: (PointerEvent event) {
          debugPrint('onPointerDown');
          selectItem(event);
        },
        onPointerMove: (event) {
          debugPrint('onPointerMove');
          selectItem(event);
        },
        onPointerUp: (PointerEvent event) {
          endSelectItem(event);
        },
      ),
    );
  }

  BoxDecoration _getGridItemBoxDecoration(int row, int col) {
    BoxDecoration boxDecoration = BoxDecoration(
      border: Border.all(color: kFluggleBoardColor, width: kFLUGGLE_BOARD_BORDER_WIDTH, style: BorderStyle.solid),
      borderRadius: _getGridItemBorderRadius(row, col),
    );

    return boxDecoration;
  }

  BorderRadius _getGridItemBorderRadius(int row, int col) {
    BorderRadius borderRadius;

    if (row == 0) {
      if (col == 0) {
        borderRadius = BorderRadius.only(topLeft: Radius.circular(9));
      } else if (col == 3) {
        borderRadius = BorderRadius.only(topRight: Radius.circular(9));
      }
    }

    if (row == 3) {
      if (col == 0) {
        borderRadius = BorderRadius.only(bottomLeft: Radius.circular(9));
      } else if (col == 3) {
        borderRadius = BorderRadius.only(bottomRight: Radius.circular(9));
      }
    }

    return borderRadius;
  }

  RowCol _getRowColFromIndex(int index) {
    return RowCol(col: (index % kGridCount), row: (index / kGridCount).floor());
  }

  Widget _buildGridLines(BuildContext context, int index) {
    debugPrint('_buildGridItems');
    var rowCol = _getRowColFromIndex(index);

    return Container(
        decoration: _getGridItemBoxDecoration(rowCol.row, rowCol.col),
        child: GridTile(
          child: Container(),
        ));
  }

  Widget _buildGridItems(BuildContext context, int index) {
    debugPrint('_buildGridItems');
    var rowCol = _getRowColFromIndex(index);

    return GridItemWidget(gridItems: widget.gridItems, letters: widget.letters, rowCol: rowCol);
  }

  void endSelectItem(PointerEvent event) {
    debugPrint('>>> endSelectItem');
    setState(() {
      currentGridItem = null;
      widget.addWord();
      widget.resetSwipedItems();
    });
  }

  void selectItem(PointerEvent event) {
    RenderBox box = gridKey.currentContext.findRenderObject();
    BoxHitTestResult result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (HitTestEntry hit in result.path) {
        HitTestTarget target = hit.target;
        if (target is GridCellRenderObject) {
          RowCol rowCol = (target as GridCellRenderObject).rowCol;
          GridItem gridItem = widget.gridItems[rowCol.row][rowCol.col];
          setState(() {
            if (widget.addSwipedGridItem(gridItem)) {
              gridItem.swiped = true;
              currentGridItem = gridItem;
            } else {
              currentGridItem = null;
            }
          });
        }
      }
    }
  }
}
