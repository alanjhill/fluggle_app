import 'package:collection/collection.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FriendListViewModel {
  FriendListViewModel({required this.database});
  final FirestoreDatabase database;

  Stream<List<AppUserFriend>> userFriendsStream() {
    Stream<List<AppUserFriend>> userFriendsCombined = Rx.combineLatest2(database.friendsStream(), database.usersStream(), (List<Friend> friends, List<AppUser> users) {
      List<AppUserFriend> userFriends = [];

      for (var friend in friends) {
        AppUser? fluggleUser;

        fluggleUser = users.firstWhereOrNull((user) => user.uid == friend.friendId);
        debugPrint('user: $fluggleUser');
        AppUserFriend userFriend;

        if (null != fluggleUser) {
          userFriend = AppUserFriend(appUser: fluggleUser, friend: friend);

          userFriends.add(userFriend);
        }
      }

      return userFriends.toList();
    });

    return userFriendsCombined;
  }
}
