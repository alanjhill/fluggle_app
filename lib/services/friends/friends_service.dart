import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final friendsServiceProvider = Provider<FriendsService>((ref) => throw UnimplementedError());

class FriendsService {
  void findFriendByEmail({required String email}) {}

  Future<Friend> addFriend(WidgetRef ref, {required String friendId}) async {
    //final firebaseAuth = context.read(firebaseAuthProvider);
    final firestoreDatabase = ref.read(databaseProvider);

    // Create the friend with a status of invited
    final friend = Friend(friendId: friendId, friendStatus: FriendStatus.invited);

    // Invite the friend with a status of requested
    await firestoreDatabase!.addFriend(inviterStatus: FriendStatus.requested, friend: friend);

    return friend;
  }
}
