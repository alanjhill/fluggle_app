import 'package:fluggle_app/widgets/empty_content.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_page.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PreviousGamesItem extends ConsumerWidget {
  PreviousGamesItem({
    required this.game,
    required this.uid,
    required this.previousGameOnTap,
  });
  final Game game;
  final String uid;
  final Function previousGameOnTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamePlayersAsyncValue = ref.watch(previousGamesPlayerStreamProvider(game.gameId!));

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
    return Column(
      children: [
        Slidable(
          key: Key(game.gameId!),
          child: Container(
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
                      Text(game.gameId!),
                    ],
                  ),
                ),
              ),
              onTap: () {
                previousGameOnTap(context, game: game);
              },
            ),
          ),
          movementDuration: Duration(milliseconds: 500),
          actionPane: SlidableBehindActionPane(),
          actions: [
            IconSlideAction(
              icon: Icons.more_horiz,
              onTap: () async {
                debugPrint('More');
              },
              //color: kFlugglePrimaryColor,
              color: Colors.transparent,
            )
          ],
          secondaryActions: [
            IconSlideAction(
              icon: Icons.more_horiz,
              onTap: () async {
                debugPrint('More');
              },
              color: Colors.transparent,
            )
          ],
        ),
        SizedBox(height: 8.0),
      ],
    );
  }

  Text _getHeadingText({required Game game, required List<Player> players, required String uid}) {
    if (game.gameStatus == GameStatus.finished) {
      return Text('Game with:', textAlign: TextAlign.left);
    } else if (game.gameStatus == GameStatus.abandoned) {
      return Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return Text('Game in progress', textAlign: TextAlign.left);
    }
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required List<Player> players, required String uid}) {
    List<Player> otherPlayers = players.where((player) => player.playerId != uid).toList();
    return Column(
      children: <Widget>[
        ListView.builder(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: otherPlayers.length,
          itemBuilder: (context, index) => _buildPlayerItem(context, game: game, player: otherPlayers[index]),
        ),
      ],
    );
  }

  Widget _buildPlayerItem(BuildContext context, {required Game game, required Player player}) {
    return Container(
      //height: 128.0,
      child: Row(
        children: <Widget>[
          Container(
            width: 16.0,
            child: game.creatorId == player.playerId ? Text('*') : null,
          ),
          Container(
            child: Container(
              padding: EdgeInsets.only(
                left: 0.0,
                top: 4.0,
                bottom: 4.0,
              ),
              child: Text(player.user!.displayName!),
            ),
          ),
          Expanded(
            child: Container(
              child: _buildPlayerScore(game: game, player: player),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerScore({required Game game, required Player player}) {
    PlayerStatus playerStatus = game.playerUids[player.playerId] as PlayerStatus;
    switch (playerStatus) {
      case PlayerStatus.invited:
      case PlayerStatus.accepted:
        return Text('-', textAlign: TextAlign.right);
      case PlayerStatus.declined:
        return Text('Declined', textAlign: TextAlign.right);
      case PlayerStatus.resigned:
        return Text('Resigned', textAlign: TextAlign.right);
      case PlayerStatus.finished:
        return Text('${player.score}', textAlign: TextAlign.right);
    }
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

      if (game.gameStatus == GameStatus.finished) {
        if (myScore > highestScore) {
          return Text('You won with $myScore points');
        } else if (myScore == highestScore) {
          return Text('You drew with $myScore points');
        } else {
          return Text('You lost with $myScore points');
        }
      } else {
        return Text('You scored $myScore points');
      }
    } else {
      return const EmptyContent();
    }
  }
}
