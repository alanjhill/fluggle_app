import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';

enum PlayerStatus { invited, accepted, declined, resigned, finished }

class Player {
  final String uid;
  FluggleUser? user;
  bool creator;
  PlayerStatus? status;
  LinkedHashMap<String, PlayerWord>? words;
  int score;

  Player({required this.uid, this.user, this.creator = false, this.status, this.words, this.score = 0});

  factory Player.fromMap(Map<String, dynamic>? map, String documentId) {
    var thing = map!['words'];

    var wordsMap;

    if (thing != null) {
      wordsMap = LinkedHashMap.from(thing);
    }

    LinkedHashMap<String, PlayerWord> playerWords = LinkedHashMap<String, PlayerWord>();
    if (wordsMap != null) {
      wordsMap.forEach((dynamic word, dynamic data) {
        playerWords[word] = PlayerWord.fromMap(data);
      });
    }
    debugPrint('Player, status: ${map["status"].toString()}');
    return Player(
      uid: documentId,
      status: PlayerStatus.values.firstWhere(
        (status) => status.toString() == map['status'],
      ),
      score: map['score'] ?? 0,
      words: playerWords,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> wordMap = {};
    if (words != null) {
      words!.forEach((word, playerWord) {
        wordMap[word] = playerWord.toMap();
      });
    }
    debugPrint(wordMap.toString());
    return {'uid': uid, 'status': status.toString(), 'words': wordMap, 'score': score};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Player && runtimeType == other.runtimeType && uid == other.uid && status == other.status && words == other.words;

  @override
  int get hashCode => uid.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'Player{uid: $uid, user: $user, status: $status, words: $words, score: $score}';
  }
}
