import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:fluggle_app/screens/friends/friends_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  static const String routeName = "friends";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: Strings.friendsPage,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              FriendsList.create(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kFluggleSecondaryColor,
        foregroundColor: kFlugglePrimaryColor,
        child: Icon(Icons.add),
        onPressed: () => null,
      ),
    );
  }
}
