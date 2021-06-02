import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/scores/scores.dart';
import 'package:fluggle_app/pages/scores/scores_banner.dart';
import 'package:fluggle_app/pages/scores/scores_footer.dart';
import 'package:fluggle_app/pages/scores/scores_header.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

// ignore: must_be_immutable
class ScoresList extends StatefulWidget {
  ScoresList({
    required this.gameData,
    required this.playerData,
    required this.uid,
    required this.saveGame,
  });

  final AsyncValue<Game> gameData;
  final AsyncValue<List<Player>?> playerData;
  final String uid;
  final Function saveGame;

  @override
  _ScoresListState createState() => _ScoresListState();
}

class _ScoresListState extends State<ScoresList> {
  GameService gameService = GameService();

  static LinkedScrollControllerGroup? _verticalControllersGroup = LinkedScrollControllerGroup();
  static List<ScrollController> _verticalScrollControllers = [];

  LinkedScrollControllerGroup? _horizontalControllersGroup = LinkedScrollControllerGroup();
  List<ScrollController> _horizontalScrollControllers = [];

  @override
  void initState() {
    super.initState();
    _horizontalScrollControllers.add(_horizontalControllersGroup!.addAndGet());
    _horizontalScrollControllers.add(_horizontalControllersGroup!.addAndGet());
    _horizontalScrollControllers.add(_horizontalControllersGroup!.addAndGet());
  }

  @override
  void dispose() {
    super.dispose();
    _verticalScrollControllers.forEach((ScrollController scrollController) {
      //scrollController.dispose();
    });

    _horizontalScrollControllers.forEach((ScrollController scrollController) {
      //scrollController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>> widget.gameData: ${widget.gameData}');
    Game? game;
    widget.gameData.when(
      data: (g) {
        game = g;
      },
      loading: () => CircularProgressIndicator(),
      error: (_, __) => {},
    );

    debugPrint('ScoresList.build, >>> game: $game');
    if (game != null) {
      if (game!.practise == true) {
        return _buildSinglePlayerScores(context, game: game!);
      } else {
        return _buildMultiPlayerScores(context, game: game!);
      }
    } else {
      return CircularProgressIndicator();
    }
  }

  Widget _buildSinglePlayerScores(BuildContext context, {required Game game}) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    List<Player> creator = [];
    widget.playerData.when(
        loading: () => {},
        data: (playerList) {
          Iterator<Player> it = playerList!.iterator;
          int index = 0;
          while (it.moveNext()) {
            Player player = it.current;
            player.playerStatus = game.playerUids![player.uid] as PlayerStatus;
            if (index == 0) {
              creator.add(player);
            }
            index++;
          }
        },
        error: (_, __) => {});

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        height: constraints.maxHeight,
        decoration: BoxDecoration(
          color: kFlugglePrimaryColor,
          border: Border.all(
            color: kFlugglePrimaryColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
          //boxShadow: [const BoxShadow(color: Colors.black, spreadRadius: -2, blurRadius: 2)],
        ),
        child: _buildScores(
          context,
          game: game,
          creator: creator,
          players: [],
        ),
      );
    });
  }

  Widget _buildMultiPlayerScores(BuildContext context, {required Game game}) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;
    List<Player> creator = [];
    List<Player> players = [];
    widget.playerData.when(
        loading: () => {},
        data: (playerList) {
          Iterator<Player> it = playerList!.iterator;
          int index = 0;
          while (it.moveNext()) {
            Player player = it.current;
            player.playerStatus = game.playerUids![player.uid] as PlayerStatus;
            if (index == 0) {
              creator.add(player);
            } else {
              players.add(player);
            }
            index++;
          }
        },
        error: (_, __) => {});

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        height: constraints.maxHeight,
        decoration: BoxDecoration(
          color: kFlugglePrimaryColor,
          border: Border.all(
            color: kFlugglePrimaryColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
          //boxShadow: [const BoxShadow(color: Colors.black, spreadRadius: -2, blurRadius: 2)],
        ),
        child: game != null
            ? _buildScores(
                context,
                game: game,
                creator: creator,
                players: players,
              )
            : CircularProgressIndicator(),
      );
    });
  }

  Widget _buildScores(BuildContext context, {required Game game, required List<Player> creator, required List<Player> players}) {
    final mediaQuery = MediaQuery.of(context);
    // Tally of all words
    Map<String, int> wordTally = {};

    // Process the scores/words
    gameService.processWords(context, game: game, creator: creator, players: players, wordTally: wordTally);

    // Only if a real game do we save the game state after processing the words
    if (game.practise == false) {
      widget.saveGame(context, game: game);
    }

    // Add two scrollControllers
    creator.forEach((_) {
      _verticalScrollControllers.add(_verticalControllersGroup!.addAndGet());
    });
    players.forEach((_) {
      _verticalScrollControllers.add(_verticalControllersGroup!.addAndGet());
    });

    final double bannerHeight = 48.0;
    final double headerHeight = 36.0;
    final double footerHeight = 96.0;

    return Container(
      color: kFluggleBoardBackgroundColor,
      padding: EdgeInsets.all(0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          debugPrint('_buildScores, constraints: ${constraints.toString()}');
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ScoresBanner(
                context: context,
                game: game,
                creator: creator,
                players: players,
                height: bannerHeight,
              ),
              ScoresHeader(
                context: context,
                game: game,
                creator: creator,
                players: players,
                height: headerHeight,
                horizontalScrollControllers: _horizontalScrollControllers,
                horizontalScrollerIndex: 0,
              ),
              Scores(
                context: context,
                game: game,
                creator: creator,
                players: players,
                wordTally: wordTally,
                height: constraints.maxHeight - bannerHeight - headerHeight - footerHeight,
                horizontalScrollControllers: _horizontalScrollControllers,
                horizontalScrollerIndex: 1,
                verticalScrollControllers: _verticalScrollControllers,
              ),
              ScoresFooter(
                context: context,
                game: game,
                creator: creator,
                players: players,
                height: footerHeight,
                horizontalScrollControllers: _horizontalScrollControllers,
                horizontalScrollerIndex: 2,
              ),
            ],
          );
        },
      ),
    );
  }
}
