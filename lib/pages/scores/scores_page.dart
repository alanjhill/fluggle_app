import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/user_view_model.dart';
import 'package:fluggle_app/pages/game/game_page.dart';
import 'package:fluggle_app/pages/scores/scores_list.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// >>> Providers

final gameStreamProvider = StreamProvider.autoDispose.family<Game, String>((ref, String gameId) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = GameViewModel(database: firestoreDatabase!);
  return vm.getGame(gameId: gameId);
});

final playerScoresStreamProvider = StreamProvider.autoDispose.family<List<Player>, String>((ref, String gameId) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = GameViewModel(database: firestoreDatabase!);
  return vm.gamePlayersStream(gameId: gameId, includeSelf: true);
});

final userStreamProvider = StreamProvider.autoDispose.family<AppUser, String>((ref, String uid) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = UserViewModel(database: firestoreDatabase!);
  return vm.findUserByUid(uid: uid);
});

/// <<< end Providers

// Need to wait for other player to finish here before we can calculate scores
class ScoresPage extends ConsumerWidget {
  static const String routeName = "/scores";

/*  final Game game;
  final List<Player> players;*/
  final GameArguments gameArguments;
  ScoresPage({required this.gameArguments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('>>> build >>> ref: $ref');

    /// Get current user
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;
    final Game game = gameArguments.game;
    final List<Player> players = gameArguments.players;

    if (game.practice == true) {
      // Single Player / practice
      final gameAsyncValue = AsyncValue.data(game);
      AppUser appUser = ref.watch(userStreamProvider(user.uid)).data?.value as AppUser;
      players[0].user = appUser;
      final playerScoresAsyncValue = AsyncValue.data(players);
      return _buildScores(context, ref, gameData: gameAsyncValue, playerData: playerScoresAsyncValue);
    } else {
      // Multi Player
      final String gameId = game.gameId!;
      debugPrint('>>> about to watch game');
      final gameAsyncValue = ref.watch(gameStreamProvider(gameId));
      debugPrint('>>> done watch game: $gameAsyncValue');
      final playerScoresAsyncValue = ref.watch(playerScoresStreamProvider(gameId));
      return _buildScores(context, ref, gameData: gameAsyncValue, playerData: playerScoresAsyncValue);
    }
  }

  Widget _buildScores(BuildContext context, WidgetRef ref, {required AsyncValue<Game> gameData, required AsyncValue<List<Player>?> playerData}) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = CustomAppBar(titleText: Strings.scoresPage);
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;

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
                  _buildScoresListWidget(
                    context,
                    height: remainingHeight * 0.8,
                    gameData: gameData,
                    playerData: playerData,
                    uid: user.uid,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Scores List Widget
  Widget _buildScoresListWidget(BuildContext context, {required double height, required AsyncValue<Game> gameData, required AsyncValue<List<Player>?> playerData, required String uid}) {
    return Container(
      height: height,
      child: ScoresList(
        gameData: gameData,
        playerData: playerData,
        uid: uid,
      ),
    );
  }
}
