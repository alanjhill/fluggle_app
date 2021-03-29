import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatefulWidget {
  static const String routeName = "/new-game";

  @override
  _NewGameScreenState createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
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
        title: const Text('New Game'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(
              child: Text('Play Friend'),
              onPressed: () => playFriend(context),
            ),
            ElevatedButton(
              child: Text('Practice'),
              onPressed: () => practise(context),
            ),
          ],
        ),
      ),
    );
  }
}
