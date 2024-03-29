import 'package:fluggle_app/pages/friends/friends_page.dart';
import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/user_view_model.dart';
import 'package:fluggle_app/pages/play_game/play_game_list.dart';
import 'package:fluggle_app/pages/start_game/start_game_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// >>> Providers
final gameViewModelStreamProvider = StreamProvider.autoDispose<List<Game>>(
  (ref) {
    final database = ref.watch(databaseProvider);
    final vm = GameViewModel(database: database!);
    return vm.myPendingGamesStream;
  },
);

final playerStreamProvider = StreamProvider.autoDispose.family<List<Player>, String>((ref, String gameId) {
  final database = ref.watch(databaseProvider);
  final vm = GameViewModel(database: database!);
  return vm.gamePlayersStream(gameId: gameId, includeSelf: true);
});

final userStreamProvider = StreamProvider.autoDispose.family<AppUser, String>((ref, String uid) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = UserViewModel(database: firestoreDatabase!);
  return vm.findUserByUid(uid: uid);
});

/// <<< end Providers

class PlayGamePage extends ConsumerWidget {
  const PlayGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final mediaQuery = MediaQuery.of(context);
    //final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;
    final PreferredSizeWidget appBar = CustomAppBar(
      titleText: Strings.playGamePage,
    );

    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final bool isSignedIn = user != null;
    final bool isAnonymous = user!.isAnonymous;

    final buttonsWidget = Container(
      //height: remainingHeight * 0.2,
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //SizedBox(height: 8.0),
          CustomRaisedButton(
            child: const Text(Strings.playFriend),
            onPressed: isSignedIn && !isAnonymous ? () => _playFriend(context) : null,
          ),
          const SizedBox(height: 8.0),
          CustomRaisedButton(
            child: const Text(Strings.practice),
            onPressed: isSignedIn ? () => _practice(context) : null,
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );

    /// Play Games Data
    final playGamesAsyncValue = ref.watch(gameViewModelStreamProvider);

    Widget _buildPlayGameListWidget(BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayGameList(data: playGamesAsyncValue, leftSwipeGame: _leftSwipeGame),
        ],
      );
    }

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: kPagePadding, left: kPagePadding, right: kPagePadding),
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
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _playFriend(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.friendsPage, arguments: FriendsArguments(backEnabled: true));
  }

  void _practice(BuildContext ctx) async {
    Navigator.of(ctx).pushNamed(
      AppRoutes.startGamePage,
      arguments: StartGameArguments(
        players: [],
      ),
    );
  }

  void _leftSwipeGame(WidgetRef ref, {required Game game, required String uid}) async {
    final gameService = ref.read(gameServiceProvider);
    if (game.creatorId == uid) {
      await gameService.deleteGame(ref, game: game);
    } else {
      await gameService.saveGame(ref, game: game, playerStatus: PlayerStatus.declined, uid: uid);
    }
  }
}
