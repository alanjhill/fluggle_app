import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/pages/start_game/start_game_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FriendItem extends StatelessWidget {
  FriendItem({
    Key? key,
    required this.appUserFriend,
  }) : super(key: key);

  final AppUserFriend appUserFriend;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key('0-${appUserFriend.friend.friendId}'),
      child: GestureDetector(
        child: ReusableCard(
          key: Key('1-${appUserFriend.friend.friendId}'),
          cardChild: _buildFriendItem(context, appUserFriend: appUserFriend),
        ),
        onTap: () {
          _playButtonPressed(context, friend: appUserFriend.appUser);
        },
      ),
      movementDuration: Duration(milliseconds: 500),
      //normalAnimationDuration: 500,
      //deleteAnimationDuration: 400,
      //performsFirstActionWithFullSwipe: true,

      actionPane: SlidableBehindActionPane(),
      actions: [
        IconSlideAction(
          icon: Icons.check_sharp,
          onTap: () async {
            debugPrint('Accept');
            // Update friend to FriendStatus.accepted
          },
          color: kFluggleLightColor,
        )
      ],
      secondaryActions: [
        IconSlideAction(
          icon: Icons.close_sharp,
          onTap: () async {
            debugPrint('Decline');
            // update friend to FriendStatus.declined
          },
          color: kFluggleLightColor,
        )
      ],
    );
  }

  void _playButtonPressed(BuildContext context, {required AppUser friend}) {
    debugPrint('Play Button Pressed');

    // Redirect to new game screen where we will pass the required data and there we will create the new game
    List<AppUser> friends = [];
    friends.add(friend);

    Navigator.of(context).pushNamed(AppRoutes.startGamePage, arguments: StartGameArguments(players: friends));
  }

  Widget _buildFriendItem(BuildContext context, {required AppUserFriend appUserFriend}) {
    return ListTile(
      title: Text(appUserFriend.appUser.displayName!),
      trailing: Container(
        margin: EdgeInsets.all(0.0),
        padding: EdgeInsets.all(0.0),
        width: 50,
        child: _getFriendStatusIcon(context, friendStatus: appUserFriend.friend.friendStatus),
      ),
    );
  }

  Widget _getFriendStatusIcon(BuildContext context, {required FriendStatus friendStatus}) {
    if (friendStatus == FriendStatus.invited) {
      //return Text('invited');
      return Icon(
        Icons.hourglass_top_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else if (friendStatus == FriendStatus.requested) {
      //return Text('requested');
      return Icon(
        Icons.person_add_alt_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else if (friendStatus == FriendStatus.accepted) {
      //return Text('accepted');
      return Icon(
        Icons.done_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else if (friendStatus == FriendStatus.declined) {
      //return Text('declined');
      return Icon(
        Icons.person_add_disabled_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else {
      return Text('');
    }
  }
}
