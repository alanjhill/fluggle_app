import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/friend.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/pages/start_game/start_game_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';

class FriendItem extends StatelessWidget {
  const FriendItem({
    Key? key,
    required this.appUserFriend,
  }) : super(key: key);

  final AppUserFriend appUserFriend;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('0-${appUserFriend.friend.friendId}'),
      direction: DismissDirection.endToStart,
      movementDuration: const Duration(milliseconds: 500),
      background: Container(
        child: const Icon(Icons.close, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      ),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove Friend'),
            content: const Text('Are you sure you want to remove your friend?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        _dismissFriend(friendId: appUserFriend.friend.friendId);
      },
      child: GestureDetector(
        child: ReusableCard(
          key: Key('1-${appUserFriend.friend.friendId}'),
          cardChild: _buildFriendItem(context, appUserFriend: appUserFriend),
        ),
        onTap: () {
          _playButtonPressed(context, friend: appUserFriend.appUser);
        },
      ),

/*      actions: [
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
      ],*/
    );
  }

  void _dismissFriend({required String friendId}) {
    debugPrint('_dismissFriend, friendId: $friendId');
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
        margin: const EdgeInsets.all(0.0),
        padding: const EdgeInsets.all(0.0),
        width: 50,
        child: _getFriendStatusIcon(context, friendStatus: appUserFriend.friend.friendStatus),
      ),
    );
  }

  Widget _getFriendStatusIcon(BuildContext context, {required FriendStatus friendStatus}) {
    if (friendStatus == FriendStatus.invited) {
      //return Text('invited');
      return const Icon(
        Icons.hourglass_top_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else if (friendStatus == FriendStatus.requested) {
      //return Text('requested');
      return const Icon(
        Icons.person_add_alt_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else if (friendStatus == FriendStatus.accepted) {
      //return Text('accepted');
      return const Icon(
        Icons.done_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else if (friendStatus == FriendStatus.declined) {
      //return Text('declined');
      return const Icon(
        Icons.person_add_disabled_sharp,
        color: Colors.white,
        size: 28.0,
      );
    } else {
      return const Text('');
    }
  }
}
