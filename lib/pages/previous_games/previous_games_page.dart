import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
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
  return vm.gamePlayersStream(gameId: gameId);
});

/// <<< end Providers

class PreviousGamesPage extends ConsumerWidget {
  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = customAppBar(title: Strings.previousGamesPage, centerTitle: true);
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;

    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final bool isSignedIn = user != null;

    /// Previous Games Data
    final previousGamesAsyncValue = watch(gameViewModelStreamProvider);

    Widget _buildPreviousGameListWidget(BuildContext context) {
      return Container(
        //padding: EdgeInsets.only(bottom: 16.0),
        //height: remainingHeight * 0.8,
        child: PreviousGamesList(data: previousGamesAsyncValue, previousGameOnTap: _previousGameOnTap),
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
                  _buildPreviousGameListWidget(context),
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
