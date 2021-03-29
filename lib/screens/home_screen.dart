import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:fluggle_app/screens/login_screen.dart';
import 'package:fluggle_app/screens/new_game_screen.dart';
import 'package:fluggle_app/screens/previous_games_screen.dart';
import 'package:fluggle_app/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "home";

  void newGame(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(NewGameScreen.routeName);
  }

  void friendsList(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(FriendsScreen.routeName);
  }

  void previousGames(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(PreviousGamesScreen.routeName);
  }

  void login(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(LoginScreen.routeName);
  }

  void signIn(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(SignInPageBuilder.routeName);
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
            Text('Welcome to Fluggle', style: TextStyle()),
            Text('A Boggle like word game written with Flutter.', style: TextStyle()),
            ElevatedButton(
              child: Text('Play'),
              onPressed: () => newGame(context),
            ),
            ElevatedButton(
              child: Text('Friends'),
              onPressed: () => friendsList(context),
            ),
            ElevatedButton(
              child: Text('Previous Games'),
              onPressed: () => previousGames(context),
            ),
            ElevatedButton(
              child: Text('Login'),
              onPressed: () => signIn(context),
            ),
          ],
        ),
      ),
    );
  }
}
