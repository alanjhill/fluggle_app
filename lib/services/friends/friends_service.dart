import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsService {
  void findFriendByEmail({required String email}) {}

  Future<Friend> addFriend(BuildContext context, {required String friendId}) async {
    final firestoreDatabase = context.read(databaseProvider);
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;
    final String uid = user.uid;

    // Create the friend with a status of invited
    final friend = Friend(friendId: friendId, friendStatus: FriendStatus.invited);

    // Invite the friend with a status of requested
    await firestoreDatabase.addFriend(inviterStatus: FriendStatus.requested, friend: friend);

    return friend;
  }
}