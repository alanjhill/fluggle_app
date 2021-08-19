import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/scores/scores_banner.dart';
import 'package:fluggle_app/pages/scores/scores_data.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScoresList extends StatefulWidget {
  ScoresList({
    required this.gameData,
    required this.playerData,
    required this.uid,
  });

  final AsyncValue<Game> gameData;
  final AsyncValue<List<Player>?> playerData;
  final String uid;

  @override
  _ScoresListState createState() => _ScoresListState();
}

class _ScoresListState extends State<ScoresList> {
  GameService gameService = GameService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
      if (game!.practice == true) {
        return _buildSinglePlayerScores(context, game: game!);
      } else {
        return _buildMultiPlayerScores(context, game: game!, uid: widget.uid);
      }
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget _buildSinglePlayerScores(BuildContext context, {required Game game}) {
    List<Player> players = [];
    widget.playerData.when(
        loading: () => {},
        data: (playerList) {
          Iterator<Player> it = playerList!.iterator;
          int index = 0;
          while (it.moveNext()) {
            Player player = it.current;
            if (index == 0) {
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
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _buildScores(
          context,
          game: game,
          players: players,
          uid: widget.uid,
        ),
      );
    });
  }

  Widget _buildMultiPlayerScores(BuildContext context, {required Game game, required String uid}) {
    List<Player> players = [];

    return widget.playerData.when(
        loading: () => CircularProgressIndicator(),
        data: (playerList) {
          Iterator<Player> it = playerList!.iterator;
          while (it.moveNext()) {
            Player player = it.current;
            players.add(player);
          }
          return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              padding: EdgeInsets.all(0.0),
              margin: EdgeInsets.all(0.0),
              height: constraints.maxHeight,
              child: game != null
                  ? _buildScores(
                      context,
                      game: game,
                      players: players,
                      uid: uid,
                    )
                  : CircularProgressIndicator(),
            );
          });
        },
        error: (_, __) => Text('Error Loading data'));
  }

  Widget _buildScores(
    BuildContext context, {
    required Game game,
    required List<Player> players,
    required String uid,
  }) {
    // Process the scores/words
    Map<String, int> wordTally = gameService.processWords(context, game: game, players: players);

    final double bannerHeight = 48.0;
    return Container(
      //color: kFluggleBoardBackgroundColor,
      //color: Color
      //padding: EdgeInsets.all(0.0),
      //margin: EdgeInsets.all(0.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          debugPrint('_buildScores, constraints: ${constraints.toString()}');
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ScoresBanner(
                context: context,
                game: game,
                players: players,
                height: bannerHeight,
              ),
              ScoresData(
                context: context,
                game: game,
                players: players,
                uid: uid,
                height: constraints.maxHeight - bannerHeight,
                width: constraints.maxWidth,
                wordTally: wordTally,
              )
            ],
          );
        },
      ),
    );
  }
}
