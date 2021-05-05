import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/player.dart';

enum GameStatus { practise, created, abandoned, finished }

class Game {
  String? gameId;
  final String creatorId;
  final Timestamp created;
  GameStatus? gameStatus;
  final List<String> letters;
  final List<String>? playerUids;
  List<Player>? players = [];

  Game({
    required this.creatorId,
    required this.created,
    required this.gameStatus,
    required this.letters,
    this.gameId,
    this.playerUids,
    this.players,
  });

  factory Game.fromMap(Map<String, dynamic>? map, String documentId) {
    return Game(
        gameId: documentId,
        creatorId: map!['creatorId'],
        created: map['created'],
        gameStatus: GameStatus.values.firstWhere(
          (status) => status.toString() == map['gameStatus'],
        ),
        playerUids: List<String>.from(map['playerUids']),
        players: [],
        letters: List<String>.from(map['letters']));
  }

  Map<String, dynamic> toMap() {
    return {'creatorId': creatorId, 'created': created, 'gameStatus': gameStatus.toString(), 'playerUids': playerUids?.toList(), 'letters': letters.toList()};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          creatorId == other.creatorId &&
          created == other.created &&
          gameStatus == other.gameStatus &&
          playerUids == other.playerUids &&
          players == other.players &&
          letters == other.letters;

  @override
  String toString() {
    return 'Game{gameId: $gameId, creatorId: $creatorId, created: $created, gameStatus: $gameStatus, letters: $letters, playerUids: $playerUids, players: $players}';
  }

  @override
  int get hashCode => gameId.hashCode ^ creatorId.hashCode ^ created.hashCode ^ gameStatus.hashCode ^ playerUids.hashCode ^ players.hashCode ^ letters.hashCode;
}
