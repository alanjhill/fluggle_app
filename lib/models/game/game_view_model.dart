import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/services/firestore/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:collection/collection.dart';

class GameViewModel {
  GameViewModel({required this.database});
  final FirestoreDatabase database;

  Stream<List<Game>> pendingGamesStream() {
    return database.myPendingGamesStream();
  }

  Stream<List<Game>> previousGamesStream() {
    return database.myPreviousGamesStream();
  }

  Stream<List<Player>> gamePlayersStream({required String gameId, bool includeSelf = false}) {
    Stream<List<Player>> playerStream = database.gamePlayerStream(gameId: gameId, includeSelf: includeSelf).map((List<Player> players) {
      return players;
    });

    Stream<List<FluggleUser>> userStream = database.usersStream().map((List<FluggleUser> users) {
      return users;
    });

    var playerList = Rx.combineLatest2(playerStream, userStream, (List<Player> players, List<FluggleUser> users) {
      return players.map((player) {
        //debugPrint('GameViewModel.gamesStream, player: ${player.toString()}');
        final FluggleUser? fluggleUser = users.firstWhereOrNull((user) => user.uid == player.uid);
        player.user = fluggleUser;
        return player;
      }).toList();
    });

    return playerList;
  }

  Stream<List<UserFriend>> userFriendsStream() {
    Stream<List<UserFriend>> userFriendsCombined =
        Rx.combineLatest2(database.friendsStream(), database.usersStream(), (List<Friend> friends, List<FluggleUser> users) {
      List<UserFriend> userFriends = [];

      friends.forEach((Friend friend) {
        FluggleUser? fluggleUser;

        fluggleUser = users.firstWhereOrNull((user) => user.uid == friend.uid);
        debugPrint('user: $fluggleUser');
        UserFriend userFriend;

        if (null != fluggleUser) {
          userFriend = UserFriend(user: fluggleUser, friend: friend);

          userFriends.add(userFriend);
        }
      });

      return userFriends.toList();
    });

    return userFriendsCombined;
  }
}
