import 'package:fluggle_app/models/user.dart';
import 'package:fluggle_app/models/friend.dart';
import 'package:flutter/material.dart';

class FriendItem extends StatelessWidget {
  FriendItem({
    Key? key,
    required this.friend,
  }) : super(key: key);

  final User friend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(friend.displayName),
        subtitle: Text('Sub Title'),
        trailing: ElevatedButton(
          child: Text('Play'),
          onPressed: () {},
        ),
      ),
    );
  }
}
