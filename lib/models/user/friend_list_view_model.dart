import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:flutter/material.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:collection/collection.dart';

class FriendListViewModel {
  FriendListViewModel({required this.database});
  final FirestoreDatabase database;

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
