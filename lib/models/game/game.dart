import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/player.dart';

enum GameStatus { created, abandoned, finished }

class Game {
  String? gameId;
  GameStatus? gameStatus;
  String? creatorId;
  final Timestamp created;
  final int gameTime;
  final bool practice;
  final List<String> letters;
  final Map<String, PlayerStatus> playerUids;
  Timestamp? finished;

  Game({
    this.gameId,
    this.creatorId,
    required this.created,
    required this.gameStatus,
    required this.gameTime,
    required this.practice,
    required this.letters,
    this.finished,
    required this.playerUids,
  });

  factory Game.fromMap(Map<String, dynamic>? map, String documentId) {
    var playerUids = <String, PlayerStatus>{};
    (map!['playerUids'] as Map<String, dynamic>).forEach((uid, status) {
      PlayerStatus playerStatus = PlayerStatus.values.firstWhere((s) => s.toString() == status);
      playerUids[uid] = playerStatus;
    });

    return Game(
        gameId: documentId,
        creatorId: map['creatorId'],
        created: map['created'],
        gameTime: map['gameTime'],
        finished: map['finished'],
        gameStatus: GameStatus.values.firstWhere(
          (status) => status.toString() == map['gameStatus'],
        ),
        practice: false,
        playerUids: playerUids,
        letters: List<String>.from(map['letters']));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'creatorId': creatorId,
      'created': created,
      'gameTime': gameTime,
      'finished': finished,
      'gameStatus': gameStatus.toString(),
      'letters': letters.toList(),
    };
    Map<String, dynamic> playerUidsMap = {};
    playerUids.forEach((uid, playerStatus) {
      playerUidsMap[uid] = playerStatus.toString();
    });
    map['playerUids'] = playerUidsMap;

    return map;
  }

  @override
  String toString() {
    return 'Game{gameId: $gameId, creatorId: $creatorId, created: gameTime: $gameTime, $created, finished: $finished, gameStatus: $gameStatus, letters: $letters, playerUids: $playerUids}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          creatorId == other.creatorId &&
          created == other.created &&
          gameTime == other.gameTime &&
          finished == other.finished &&
          gameStatus == other.gameStatus &&
          letters == other.letters &&
          playerUids == other.playerUids;
  @override
  int get hashCode => gameId.hashCode ^ creatorId.hashCode ^ gameTime.hashCode ^ created.hashCode ^ gameStatus.hashCode ^ letters.hashCode ^ playerUids.hashCode;
}
