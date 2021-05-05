import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:fluggle_app/screens/play_game/play_game_list.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayGameScreen extends StatelessWidget {
  static const String routeName = "play-game";

  final GameService gameService = GameService();

  void playFriend(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(FriendsScreen.routeName);
  }

  void practise(BuildContext ctx) async {
    Game game = await gameService.createGame(ctx, persist: false, gameStatus: GameStatus.practise);
    Navigator.of(ctx).pushNamed(GameScreen.routeName, arguments: game);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final FirebaseAuthService auth = Provider.of<FirebaseAuthService>(context, listen: false);
    final bool signedIn = auth.isSignedIn();
    final PreferredSizeWidget appBar = customAppBar(title: Strings.playGame, centerTitle: true);
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;

    final buttonsWidget = Container(
      height: remainingHeight * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            child: Text('Play Friend'),
            onPressed: signedIn ? () => playFriend(context) : null,
          ),
          ElevatedButton(
            child: Text('Practice'),
            onPressed: () => practise(context),
          ),
        ],
      ),
    );

    final playGameListWidget = Container(
      padding: EdgeInsets.only(bottom: 16.0),
      height: remainingHeight * 0.8,
      child: PlayGameList.create(context),
    );

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buttonsWidget,
                  playGameListWidget,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
