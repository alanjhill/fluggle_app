import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game_state.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/models/game_board/row_col.dart';
import 'package:fluggle_app/pages/game/game_cube.dart';
import 'package:fluggle_app/pages/game/grid_cell.dart';
import 'package:fluggle_app/pages/game/swipe_lines.dart';
import 'package:fluggle_app/utils/dictionary.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameBoard extends ConsumerStatefulWidget {
  final List<String> letters;
  final List<List<GridItem>> gridItems;
  Dictionary? dictionary;

  GameBoard({
    required this.letters,
    required this.gridItems,
    this.dictionary,
  });

  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  GlobalKey? gridKey = GlobalKey();
  GridItem? currentGridItem;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    print('kToolbarHeight: $kToolbarHeight');
    double gridSize = mediaQuery.size.width - kGameBoardPadding / 2;

    // Grid Lines - first item in the stack
    final gridLines = GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kGridCount,
      ),
      itemBuilder: _buildGridLines,
      itemCount: kGridCount * kGridCount,
      physics: const NeverScrollableScrollPhysics(),
    );

    // Swipe Lines - second item in the stack
    final gameStateNotifier = ref.watch(gameStateProvider.notifier);
    final swipedGridItems = gameStateNotifier.getSwipedGridItems();
    final swipeLines = SwipeLines(swipedGridItems: swipedGridItems, gridSize: gridSize);

    // Grid Cells containing grid
    final gameCubes = GridView.builder(
      key: gridKey,
      shrinkWrap: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kGridCount,
      ),
      itemBuilder: _buildGameCubes,
      itemCount: kGridCount * kGridCount,
      physics: const NeverScrollableScrollPhysics(),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: kGameBoardPadding / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: kFluggleBoardBorderColor,
          width: kFluggleBoardBorderWidth / 2.0,
        ),
      ),
      child: Listener(
        child: Stack(
          children: <Widget>[
            gridLines,
            swipeLines,
            gameCubes,
          ],
        ),
        onPointerDown: (PointerEvent event) {
          debugPrint('onPointerDown');
          _selectItem(ref, event);
        },
        onPointerMove: (event) {
          debugPrint('onPointerMove');
          _selectItem(ref, event);
        },
        onPointerUp: (PointerEvent event) {
          _endSelectItem(ref, event);
        },
      ),
    );
  }

  BoxDecoration _getGridItemBoxDecoration(RowCol rowCol) {
    BoxDecoration boxDecoration = BoxDecoration(
      border: Border.all(color: kFluggleBoardBorderColor, width: kFluggleBoardBorderWidth / 2.0, style: BorderStyle.solid),
      borderRadius: _getGridItemBorderRadius(rowCol),
    );

    return boxDecoration;
  }

  BorderRadius? _getGridItemBorderRadius(RowCol rowCol) {
    BorderRadius? borderRadius;

    if (rowCol.row == 0) {
      if (rowCol.col == 0) {
        borderRadius = BorderRadius.only(topLeft: Radius.circular(9));
      } else if (rowCol.col == 3) {
        borderRadius = BorderRadius.only(topRight: Radius.circular(9));
      }
    }

    if (rowCol.row == 3) {
      if (rowCol.col == 0) {
        borderRadius = BorderRadius.only(bottomLeft: Radius.circular(9));
      } else if (rowCol.col == 3) {
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
        decoration: _getGridItemBoxDecoration(rowCol),
        child: GridTile(
          child: Container(),
        ));
  }

  Widget _buildGameCubes(BuildContext context, int index) {
    return GameCube(
      rowCol: _getRowColFromIndex(index),
      gridItems: widget.gridItems,
      letter: widget.letters[index],
    );
  }

  void _selectItem(WidgetRef ref, PointerEvent event) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    if (gameStateNotifier.state.gameStarted) {
      RenderBox box = gridKey!.currentContext!.findRenderObject() as RenderBox;
      BoxHitTestResult result = BoxHitTestResult();
      Offset? local = box.globalToLocal(event.position);
      if (box.hitTest(result, position: local)) {
        for (HitTestEntry hit in result.path) {
          HitTestTarget? target = hit.target;
          if (target is GridCellRenderObject) {
            RowCol rowCol = target.rowCol;
            GridItem gridItem = widget.gridItems[rowCol.row][rowCol.col];
            setState(() {
              if (gameStateNotifier.addSwipedGridItem(gridItem)) {
                gridItem.swiped = true;
                currentGridItem = gridItem;
              } else {
                currentGridItem = null;
              }
              gameStateNotifier.updateCurrentWord();
            });
          }
        }
      }
    }
  }

  void _endSelectItem(WidgetRef ref, PointerEvent event) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    if (gameStateNotifier.state.gameStarted) {
      setState(() {
        currentGridItem = null;
        gameStateNotifier.addWord(widget.dictionary!);
        gameStateNotifier.resetSwipedItems();
      });
    }
  }
}
