import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/screens/start_game/start_game_screen.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class FriendItem extends StatelessWidget {
  FriendItem({
    Key? key,
    required this.friend,
  }) : super(key: key);

  final FluggleUser friend;

  void _playButtonPressed(BuildContext context, {required FluggleUser friend}) {
    debugPrint('Play Button Pressed');

    // Redirect to new game screen where we will pass the required data and there we will create the new game
    List<FluggleUser> friends = [];
    friends.add(friend);

    Navigator.of(context).pushNamed(StartGameScreen.routeName, arguments: StartGameArguments(players: friends));
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: Key('0-${friend.uid}'),
      child: GestureDetector(
        child: ReusableCard(
          key: Key('1-${friend.uid}'),
          cardChild: Text(friend.displayName),
        ),
        onTap: () {
          _playButtonPressed(context, friend: friend);
        },
      ),
      normalAnimationDuration: 500,
      deleteAnimationDuration: 400,
      leadingActions: [
        SwipeAction(
          content: Container(child: Icon(Icons.more_horiz)),
          onTap: (handler) async {
            debugPrint('More');
          },
          color: kFlugglePrimaryColor,
        )
      ],
    );
  }
}
