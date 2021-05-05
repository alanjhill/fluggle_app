import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/screens/scores/scores_list.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Need to wait for other player to finish here before we can calculate scores
class ScoresScreen extends StatelessWidget {
  static const String routeName = "/scores";

  final Game game;
  ScoresScreen({required this.game});

  final GameService gameService = GameService();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = customAppBar(title: Strings.scores, centerTitle: true);
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;

    debugPrint('ScoresScreen.mediaQuery: ${mediaQuery.toString()}');

    // Scores List Widget
    final scoresListWidget = Container(
      padding: EdgeInsets.all(16.0),
      height: remainingHeight * 0.8,
      child: ScoresList.create(
        context,
        gameId: game.gameId!,
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            scoresListWidget,
          ],
        ),
      ),
    );
  }
}
