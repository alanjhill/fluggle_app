import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/player.dart';

enum GameStatus { created, abandoned, finished }

class Game {
  String? gameId;
  GameStatus? gameStatus;
  final String creatorId;
  final Timestamp created;
  final bool practise;
  final List<String> letters;
  final Map<String, PlayerStatus>? playerUids;
  Timestamp? finished;
  // Not persisted
  List<Player>? players = [];

  Game({
    this.gameId,
    required this.creatorId,
    required this.created,
    required this.gameStatus,
    required this.practise,
    required this.letters,
    this.finished,
    this.playerUids,
    this.players,
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
        finished: map['finished'],
        gameStatus: GameStatus.values.firstWhere(
          (status) => status.toString() == map['gameStatus'],
        ),
        practise: false,
        playerUids: playerUids,
        players: [],
        letters: List<String>.from(map['letters']));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'creatorId': creatorId,
      'created': created,
      'finished': finished,
      'gameStatus': gameStatus.toString(),
      'letters': letters.toList(),
    };
    Map<String, dynamic> playerUidsMap = {};
    playerUids!.forEach((uid, playerStatus) {
      playerUidsMap[uid] = playerStatus.toString();
    });
    map['playerUids'] = playerUidsMap;

    return map;
  }

  @override
  String toString() {
    return 'Game{gameId: $gameId, creatorId: $creatorId, created: $created, finished: $finished, gameStatus: $gameStatus, letters: $letters, playerUids: $playerUids, players: $players}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Game &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          creatorId == other.creatorId &&
          created == other.created &&
          finished == other.finished &&
          gameStatus == other.gameStatus &&
          letters == other.letters &&
          playerUids == other.playerUids &&
          players == other.players;
  @override
  int get hashCode => gameId.hashCode ^ creatorId.hashCode ^ created.hashCode ^ gameStatus.hashCode ^ letters.hashCode ^ playerUids.hashCode ^ players.hashCode;
}
