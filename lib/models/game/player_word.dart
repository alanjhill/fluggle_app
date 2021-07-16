import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';

class PlayerWord {
  GameWord gameWord;
  List<GridItem> gridItems;

  PlayerWord({required this.gameWord, required this.gridItems});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['gameWord'] = gameWord.toMap();

    map['gridItems'] = gridItems.map((GridItem gridItem) {
      return gridItem.toMap();
    }).toList();

    return map;
  }

  factory PlayerWord.fromMap(Map<String, dynamic>? map) {
    PlayerWord playerWord = PlayerWord(
      gameWord: GameWord.fromMap(map!['gameWord']),
      gridItems: List<GridItem>.from(
        map['gridItems'].map((gi) {
          return GridItem.fromMap(gi);
        }),
      ),
    );

    return playerWord;
  }
}
