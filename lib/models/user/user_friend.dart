import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/models/user/friend.dart';

class UserFriend {
  final FluggleUser user;
  final Friend friend;

  UserFriend({required this.user, required this.friend});
}
