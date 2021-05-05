import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/play_game/play_game_screen.dart';
import 'package:fluggle_app/screens/previous_games/previous_games_screen.dart';
import 'package:fluggle_app/screens/sign_in/sign_in_manager.dart';
import 'package:fluggle_app/screens/sign_in/sign_in_page.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:fluggle_app/widgets/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreenBuilder extends StatelessWidget {
  static const String routeName = "home";

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService auth = Provider.of<FirebaseAuthService>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, SignInManager manager, __) => HomeScreen._(
              isLoading: isLoading.value,
              manager: manager,
              title: Strings.appName,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen._({
    Key? key,
    required this.isLoading,
    required this.manager,
    required this.title,
  }) : super(key: key);

  final SignInManager manager;
  final String title;
  final bool isLoading;

  void newGame(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(PlayGameScreen.routeName);
  }

  void friendsList(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(FriendsScreen.routeName);
  }

  void previousGames(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(PreviousGamesScreen.routeName);
  }

  void signIn(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(SignInPageBuilder.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final bool signedIn = manager.auth.isSignedIn();

    return Scaffold(
      appBar: customAppBar(
        title: Strings.appName,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Welcome to Fluggle',
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'A Boggle like word game written with Flutter.',
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                ElevatedButton(
                  child: Text('Play'),
                  onPressed: () => newGame(context),
                ),
                ElevatedButton(
                  child: Text('Friends'),
                  onPressed: signedIn ? () => friendsList(context) : null,
                ),
                ElevatedButton(
                  child: Text('Previous Games'),
                  onPressed: signedIn ? () => previousGames(context) : null,
                ),
                ElevatedButton(
                  child: Text('Login'),
                  onPressed: () => signIn(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
