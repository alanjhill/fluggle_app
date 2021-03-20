import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/game_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "/";

  void playGame(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(GameScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kFlugglePrimaryColor,
        title: const Text('Fluggle'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Welcome to Fluggle, a Boggle like word game written with Flutter.'),
            ElevatedButton(
              child: Text('Play'),
              onPressed: () => playGame(context),
            ),
          ],
        ),
      ),
    );
  }
}
