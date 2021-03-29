import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/user.dart';
import 'package:fluggle_app/models/friend.dart';
import 'package:fluggle_app/services/firestore_database.dart';
import 'package:fluggle_app/screens/friends/friends_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  static const String routeName = "/friends";

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget? appBar = _buildAppBar(context);
    final database = Provider.of<FirestoreDatabase>(context, listen: false);
    return Provider<FirestoreDatabase>(
      create: (context) => database,
      child: Scaffold(
        appBar: appBar,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FriendsList.create(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kFlugglePrimaryColor,
      leadingWidth: 120,
      title: const Text('Fluggle'),
    );
  }
}
