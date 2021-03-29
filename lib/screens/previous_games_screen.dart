import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:flutter/material.dart';

class PreviousGamesScreen extends StatefulWidget {
  static const String routeName = "/previous-games";

  @override
  _PreviousGamesScreenState createState() => _PreviousGamesScreenState();
}

class _PreviousGamesScreenState extends State<PreviousGamesScreen> {
  void playFriend(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(FriendsScreen.routeName);
  }

  void practise(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(GameScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kFlugglePrimaryColor,
        title: const Text('Previous Games'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[],
        ),
      ),
    );
  }
}
