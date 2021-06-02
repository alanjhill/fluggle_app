import 'dart:collection';

import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:flutter/material.dart';

enum PlayerStatus { invited, accepted, declined, resigned, finished }

class Player {
  final String uid;
  AppUser? user;
  bool creator;
  LinkedHashMap<String, PlayerWord>? words;
  PlayerStatus? playerStatus;
  int score;

  Player({required this.uid, this.user, this.creator = false, this.words, this.score = 0});

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
    return Player(
      uid: documentId,
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
    return {'uid': uid, 'words': wordMap, 'score': score};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          user == other.user &&
          creator == other.creator &&
          words == other.words &&
          score == other.score;

  @override
  int get hashCode => uid.hashCode ^ user.hashCode ^ creator.hashCode ^ words.hashCode ^ score.hashCode;

  @override
  String toString() {
    return 'Player{uid: $uid, user: $user, creator: $creator, words: $words, score: $score}';
  }
}
