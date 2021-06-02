import 'package:fluggle_app/common_widgets/list_items_builder.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_page.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';

// ignore: must_be_immutable
class PreviousGamesItem extends ConsumerWidget {
  PreviousGamesItem({required this.game, required this.uid, required this.previousGameOnTap});
  final Game game;
  final String uid;
  final Function previousGameOnTap;

  /// Controller for swipe actions
  SwipeActionController? controller;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    controller = SwipeActionController(selectedIndexPathsChangeCallback: (changedIndexPaths, selected, currentCount) {
      debugPrint('cell at ${changedIndexPaths.toString()} is/are ${selected ? 'selected' : 'unselected'} ,current selected count is $currentCount');
    });

    final gamePlayersAsyncValue = watch(previousGamesPlayerStreamProvider(game.gameId!));

    return SwipeActionCell(
      key: Key(game.gameId!),
      child: GestureDetector(
        child: ReusableCard(
          key: Key('${game.gameId}'),
          cardChild: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //Text('${widget.game.gameId}'),
              _getHeadingText(game: game, uid: uid),
              _buildPlayers(context, data: gamePlayersAsyncValue, game: game, uid: uid),
              //Text('${DateFormat.E().add_Hm().format(widget.game.created.toDate())}'),
            ],
          ),
        ),
        onTap: () {
          previousGameOnTap(context, game: game);
        },
      ),
      normalAnimationDuration: 500,
      deleteAnimationDuration: 400,
      leadingActions: [
        SwipeAction(
          content: Container(child: Icon(Icons.more_horiz)),
          onTap: (handler) async {
            debugPrint('More');
          },
          color: kFlugglePrimaryColor,
        )
      ],
      trailingActions: [
        SwipeAction(
          content: Container(child: Icon(Icons.more_horiz)),
          onTap: (handler) async {
            debugPrint('More');
          },
          color: kFlugglePrimaryColor,
        )
      ],
    );
  }

  Text _getHeadingText({required Game game, required String uid}) {
    if (game.gameStatus == GameStatus.finished) {
      return Text('You played a game with:', textAlign: TextAlign.left);
    } else if (game.gameStatus == GameStatus.abandoned) {
      return Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return Text('Game complete', textAlign: TextAlign.left);
    }
  }

  Widget _getGameWinner({required List<Player> playerList}) {
    int maxScore = 0;
    Map<Player, int> scores = {};
    playerList.forEach((Player player) {
      scores[player] = player.score;
      if (player.score > maxScore) {
        maxScore = player.score;
      }
    });

    List<Player> winningPlayers = [];
    scores.forEach((Player player, int score) {
      if (score == maxScore) {
        winningPlayers.add(player);
      }
    });

    if (winningPlayers.length == 0) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Container(
          child: Text(
            'No winners',
            textAlign: TextAlign.right,
          ),
        ),
      ]);
    } else if (winningPlayers.length == 1) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        Container(
          child: Text(
            '${winningPlayers[0].user!.displayName} won',
            textAlign: TextAlign.right,
          ),
        ),
      ]);
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Text(
              'It\'s a draw',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required data, required String uid}) {
    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[
          ListItemsBuilder<Player>(
            data: data,
            itemBuilder: (context, player) => _buildPlayerItem(context, player: player),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerItem(BuildContext context, {required Player player}) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 8.0,
            bottom: 8.0,
          ),
          child: Text('${player.user?.displayName}'),
        ),
      ],
    );
  }
}
