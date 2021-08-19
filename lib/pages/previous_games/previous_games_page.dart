import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_list.dart';
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
    return vm.myPreviousGamesStream;
  },
);

final previousGamesPlayerStreamProvider = StreamProvider.autoDispose.family<List<Player>, String>((ref, String gameId) {
  final database = ref.watch(databaseProvider);
  final vm = GameViewModel(database: database);
  return vm.gamePlayersStream(gameId: gameId, includeSelf: true);
});

/// <<< end Providers

class PreviousGamesPage extends ConsumerWidget {
  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //final mediaQuery = MediaQuery.of(context);
    //final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;
    //final firebaseAuth = context.read(firebaseAuthProvider);
    //final user = firebaseAuth.currentUser;
    //final bool isSignedIn = user != null;
    final PreferredSizeWidget appBar = CustomAppBar(titleText: Strings.previousGamesPage);

    /// Previous Games Data
    final previousGamesAsyncValue = watch(gameViewModelStreamProvider);

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(top: kPagePadding, left: kPagePadding, right: kPagePadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  PreviousGamesList(
                    data: previousGamesAsyncValue,
                    previousGameOnTap: _previousGameOnTap,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _previousGameOnTap(BuildContext context, {required Game game}) {
    debugPrint('>>> _previousGameOnTap');
    Navigator.of(context).pushNamed(AppRoutes.scoresPage, arguments: game);
  }
}
