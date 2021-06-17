import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class GameViewModel {
  GameViewModel({required this.database});
  final FirestoreDatabase database;

  Stream<Game> getGame({required String gameId}) {
    return database.gameStream(gameId: gameId);
  }

  Stream<List<Game>> get myPendingGamesStream => database.myPendingGamesStream;

  Stream<List<Game>> get myPreviousGamesStream => database.myPreviousGamesStream;

  Stream<List<Player>> gamePlayersStream({required String gameId, bool includeSelf = false}) {
    debugPrint('>>> gamePlayersStream >>>');
    Stream<List<Player>> playerStream = database.gamePlayerStream(gameId: gameId, includeSelf: includeSelf).map((List<Player> players) {
      return players;
    });

    Stream<List<AppUser>> userStream = database.usersStream().map((List<AppUser> users) {
      return users;
    });

    var playerList = Rx.combineLatest2(playerStream, userStream, (List<Player> players, List<AppUser> users) {
      return players.map((player) {
        final AppUser? fluggleUser = users.firstWhereOrNull((user) => user.uid == player.playerId);
        player.user = fluggleUser;
        return player;
      }).toList();
    });

    return playerList;
  }

  Stream<List<AppUserFriend>> userFriendsStream() {
    Stream<List<AppUserFriend>> userFriendsCombined =
        Rx.combineLatest2(database.friendsStream(), database.usersStream(), (List<Friend> friends, List<AppUser> users) {
      List<AppUserFriend> userFriends = [];

      friends.forEach((Friend friend) {
        AppUser? fluggleUser;

        fluggleUser = users.firstWhereOrNull((user) => user.uid == friend.friendId);
        debugPrint('user: $fluggleUser');
        AppUserFriend userFriend;

        if (null != fluggleUser) {
          userFriend = AppUserFriend(appUser: fluggleUser, friend: friend);

          userFriends.add(userFriend);
        }
      });

      return userFriends.toList();
    });

    return userFriendsCombined;
  }
}
