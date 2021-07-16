import 'package:fluggle_app/common_widgets/empty_content.dart';
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
  PreviousGamesItem({
    required this.game,
    required this.uid,
    required this.previousGameOnTap,
  });
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

    List<Player> players = [];
    return gamePlayersAsyncValue.when(
      data: (List<Player> items) {
        if (items.isNotEmpty) {
          players.addAll(items);
        }
        return _buildPreviousGameCard(context, game: game, players: players, uid: uid);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now: $error, $stackTrace',
      ),
    );
  }

  Widget _buildPreviousGameCard(BuildContext context, {required Game game, required List<Player> players, required String uid}) {
    return SwipeActionCell(
      key: Key(game.gameId!),
      child: GestureDetector(
        child: ReusableCard(
          key: Key(game.gameId!),
          cardChild: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _getHeadingText(game: game, players: players, uid: uid),
                _buildPlayers(context, game: game, players: players, uid: uid),
                _buildFooterText(context, game: game, players: players, uid: uid),
              ],
            ),
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

  Text _getHeadingText({required Game game, required List<Player> players, required String uid}) {
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
    for (var player in playerList) {
      scores[player] = player.score;
      if (player.score > maxScore) {
        maxScore = player.score;
      }
    }

    List<Player> winningPlayers = [];
    scores.forEach((Player player, int score) {
      if (score == maxScore) {
        winningPlayers.add(player);
      }
    });

    if (winningPlayers.isEmpty) {
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

  Widget _buildPlayers(BuildContext context, {required Game game, required List<Player> players, required String uid}) {
    List<Player> otherPlayers = players.where((player) => player.playerId != uid).toList();
    return Column(
      children: <Widget>[
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: otherPlayers.length,
          itemBuilder: (context, index) => _buildPlayerItem(context, player: otherPlayers[index]),
        ),
      ],
    );
  }

  Widget _buildPlayerItem(BuildContext context, {required Player player}) {
    return Container(
      //height: 128.0,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: 16.0,
                top: 8.0,
                bottom: 8.0,
              ),
              child: Text(player.user!.displayName),
            ),
          ),
          Expanded(
            child: Container(
              child: Text('${player.score}', textAlign: TextAlign.right),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFooterText(BuildContext context, {required Game game, required List<Player> players, required String uid}) {
    if (players.isNotEmpty) {
      Player me = players.firstWhere((player) => player.playerId == uid);
      int myScore = me.score;
      int highestScore = 0;
      for (var player in players) {
        if (player.playerId != uid) {
          if (player.score > highestScore) {
            highestScore = player.score;
          }
        }
      }

      if (myScore > highestScore) {
        return Text('You won with $myScore points');
      } else if (myScore == highestScore) {
        return Text('You drew with $myScore points');
      } else {
        return Text('You lost with $myScore points');
      }
    } else {
      return const EmptyContent();
    }
  }
}
