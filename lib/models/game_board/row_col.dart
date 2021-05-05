class RowCol {
  final int row;
  final int col;

  RowCol({this.row = -1, this.col = -1});

  @override
  String toString() {
    return 'RowCol{row: $row, col: $col}';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();

    map['row'] = row;
    map['col'] = col;

    return map;
  }
}
