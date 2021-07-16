import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/user_view_model.dart';
import 'package:fluggle_app/pages/scores/scores_list.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// >>> Providers

final gameStreamProvider = StreamProvider.autoDispose.family<Game, String>((ref, String gameId) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = GameViewModel(database: firestoreDatabase);
  return vm.getGame(gameId: gameId);
});

final playerScoresStreamProvider = StreamProvider.autoDispose.family<List<Player>, String>((ref, String gameId) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = GameViewModel(database: firestoreDatabase);
  return vm.gamePlayersStream(gameId: gameId, includeSelf: true);
});

final userStreamProvider = StreamProvider.autoDispose.family<AppUser, String>((ref, String uid) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = UserViewModel(database: firestoreDatabase);
  return vm.findUserByUid(uid: uid);
});

/// <<< end Providers

// Need to wait for other player to finish here before we can calculate scores
class ScoresPage extends ConsumerWidget {
  static const String routeName = "/scores";

  final Game game;
  ScoresPage({required this.game});

  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    /// Get current user
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;

    if (game.practise == true) {
      // Single Player / practice
      final gameAsyncValue = AsyncValue.data(game);
      AppUser appUser = watch(userStreamProvider(user.uid)).data?.value as AppUser;
      List<Player>? players = game.players;
      players![0].user = appUser;
      final playerScoresAsyncValue = AsyncValue.data(players);
      return _buildScores(context, gameData: gameAsyncValue, playerData: playerScoresAsyncValue);
    } else {
      // Multi Player
      final String gameId = game.gameId!;
      debugPrint('>>> about to watch game');
      final gameAsyncValue = watch(gameStreamProvider(gameId));
      debugPrint('>>> done watch game: $gameAsyncValue');
      final playerScoresAsyncValue = watch(playerScoresStreamProvider(gameId));
      return _buildScores(context, gameData: gameAsyncValue, playerData: playerScoresAsyncValue);
    }
  }

  Widget _buildScores(BuildContext context, {required AsyncValue<Game> gameData, required AsyncValue<List<Player>?> playerData}) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = CustomAppBar(title: Text(Strings.scoresPage));
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;
    final firebaseAuth = context.read(firebaseAuthProvider);
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
        saveGame: saveGame,
      ),
    );
  }

  bool saveGame(BuildContext context, {required Game game}) {
    final firestoreDatabase = context.read(databaseProvider);
    game.gameStatus = GameStatus.finished;
    firestoreDatabase.saveGame(game: game).then((_) {
      debugPrint('Game saved');
      return true;
    });
    return false;
  }
}
