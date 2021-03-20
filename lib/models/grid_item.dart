class GridItem {
  int row;
  int col;
  String letter;
  bool swiped;

  GridItem({this.row, this.col, this.letter, this.swiped = false});

  bool isAdjacent(GridItem otherGridItem) {
    bool adjacent = false;
    if (otherGridItem != null) {
      int cols = (otherGridItem.col - this.col).abs();
      int rows = (otherGridItem.row - this.row).abs();
      adjacent = ([0, 1].contains(cols) && [0, 1].contains(rows));
    }
    return adjacent;
  }
}
