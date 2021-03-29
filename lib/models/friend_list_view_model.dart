import 'package:fluggle_app/models/friend.dart';
import 'package:fluggle_app/models/user.dart';
import 'package:fluggle_app/services/firestore_database.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluggle_app/models/user_friend.dart';
import 'package:collection/collection.dart';

class FriendListViewModel {
  FriendListViewModel({required this.database});
  final FirestoreDatabase database;

  Stream<List<UserFriend>> userFriendsStream() {
    Stream<List<UserFriend>> userFriends = Rx.combineLatest2(database.friendsStream(), database.usersStream(), (List<Friend> friends, List<User> users) {
      return friends.map((friend) {
        final User? user = users.firstWhereOrNull((user) => user.uid == friend.uid);
        UserFriend userFriend = UserFriend(user, friend);
        return userFriend;
      }).toList();
    });

    return userFriends;
  }
}
