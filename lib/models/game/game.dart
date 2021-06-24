import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/player.dart';

enum GameStatus { created, abandoned, finished }

class Game {
  String? gameId;
  final String creatorId;
  final Timestamp created;
  GameStatus? gameStatus;
  final bool? practise;
  final List<String> letters;
  final Map<String, PlayerStatus>? playerUids;

  // Not persisted
  List<Player>? players = [];
  bool include = true;

  Game({
    required this.creatorId,
    required this.created,
    required this.gameStatus,
    required this.letters,
    this.practise = false,
    this.gameId,
    this.playerUids,
    this.players,
  });

  factory Game.fromMap(Map<String, dynamic>? map, String documentId) {
    var playerUids = Map<String, PlayerStatus>();
    (map!['playerUids'] as Map<String, dynamic>).forEach((uid, status) {
      PlayerStatus playerStatus = PlayerStatus.values.firstWhere((s) => s.toString() == status);
      playerUids[uid] = playerStatus;
    });

    return Game(
        gameId: documentId,
        creatorId: map['creatorId'],
        created: map['created'],
        gameStatus: GameStatus.values.firstWhere(
          (status) => status.toString() == map['gameStatus'],
        ),
        practise: map['practice'],
        playerUids: playerUids,
        players: [],
        letters: List<String>.from(map['letters']));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'creatorId': creatorId,
      'created': created,
      'gameStatus': gameStatus.toString(),
      'practice': practise,
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
    return 'Game{gameId: $gameId, creatorId: $creatorId, created: $created, gameStatus: $gameStatus, letters: $letters, playerUids: $playerUids, players: $players, include: $include}';
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
          letters == other.letters &&
          playerUids == other.playerUids &&
          players == other.players &&
          include == other.include;

  @override
  int get hashCode =>
      gameId.hashCode ^
      creatorId.hashCode ^
      created.hashCode ^
      gameStatus.hashCode ^
      letters.hashCode ^
      playerUids.hashCode ^
      players.hashCode ^
      include.hashCode;
}
