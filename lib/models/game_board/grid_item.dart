class GridItem {
  int row;
  int col;
  String letter;
  bool swiped;

  GridItem({this.row = 0, this.col = 0, this.letter = '', this.swiped = false});

  bool isAdjacent(GridItem? otherGridItem) {
    bool adjacent = false;
    if (otherGridItem != null) {
      int cols = (otherGridItem.col - this.col).abs();
      int rows = (otherGridItem.row - this.row).abs();
      adjacent = ([0, 1].contains(cols) && [0, 1].contains(rows));
    }
    return adjacent;
  }

  factory GridItem.fromMap(Map<String, dynamic>? map) {
    return GridItem(
      row: map!['row'],
      col: map['col'],
      letter: map['letter'],
      swiped: map['swiped'],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['row'] = row;
    map['col'] = col;
    map['letter'] = letter;
    map['swiped'] = swiped;

    return map;
  }
}
