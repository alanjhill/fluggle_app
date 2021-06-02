import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/play_game/play_game_list.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// >>> Providers
final gameViewModelStreamProvider = StreamProvider.autoDispose<List<Game>>(
  (ref) {
    final database = ref.watch(databaseProvider);
    final vm = GameViewModel(database: database);
    return vm.myPendingGamesStream;
  },
);

final playerStreamProvider = StreamProvider.autoDispose.family<List<Player>, String>((ref, String gameId) {
  final database = ref.watch(databaseProvider);
  final vm = GameViewModel(database: database);
  return vm.gamePlayersStream(gameId: gameId);
});

/// <<< end Providers

class PlayGamePage extends ConsumerWidget {
  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = customAppBar(title: Strings.playGamePage, centerTitle: true);
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;

    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final bool isSignedIn = user != null;

    final buttonsWidget = Container(
      //height: remainingHeight * 0.2,
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //SizedBox(height: 8.0),
          CustomRaisedButton(
            child: Text('Play Friend'),
            onPressed: isSignedIn ? () => playFriend(context) : null,
          ),
          SizedBox(height: 8.0),
          CustomRaisedButton(
            child: Text('Practice'),
            onPressed: () => practise(context),
          ),
        ],
      ),
    );

    /// Play Games Data
    final playGamesAsyncValue = watch(gameViewModelStreamProvider);

    Widget _buildPlayGameListWidget(BuildContext context) {
      return Container(
        //height: remainingHeight * 0.8,
        child: PlayGameList(data: playGamesAsyncValue),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buttonsWidget,
                  if (isSignedIn) _buildPlayGameListWidget(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void playFriend(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.friendsPage);
  }

  void practise(BuildContext ctx) async {
    // Create a basic Game object for a practise game
    Game game = gameService.createPracticeGame(ctx);
    Navigator.of(ctx).pushNamed(AppRoutes.gamePage, arguments: game);
  }
}
