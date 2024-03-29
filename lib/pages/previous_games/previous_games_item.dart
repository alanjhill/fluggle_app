import 'package:fluggle_app/pages/game/game_page.dart';
import 'package:fluggle_app/widgets/empty_content.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_page.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviousGamesItem extends ConsumerWidget {
  const PreviousGamesItem({
    Key? key,
    required this.game,
    required this.uid,
    required this.previousGameOnTap,
    required this.leftSwipeGame,
  }) : super(key: key);
  final Game game;
  final String uid;
  final Function previousGameOnTap;
  final Function leftSwipeGame;

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
      loading: (_) => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace, previousValue) => EmptyContent(
        title: 'Something went wrong',
        message: 'Can\'t load items right now: $error, $stackTrace',
      ),
    );
  }

  Widget _buildPreviousGameCard(BuildContext context, {required Game game, required List<Player> players, required String uid}) {
    return Column(
      children: [
        Dismissible(
          key: Key(game.gameId!),
          direction: DismissDirection.endToStart,
          movementDuration: const Duration(milliseconds: 300),
          background: Container(
            child: const Icon(Icons.delete, color: Colors.white, size: 40),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(
              right: 20,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
          ),
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to remove the item from your cart?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Yes'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            await leftSwipeGame(context, game: game, uid: uid);
          },
          child: GestureDetector(
            child: ReusableCard(
              key: Key(game.gameId!),
              cardChild: Column(
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
            onTap: () {
              GameArguments gameArgs = GameArguments(game: game, players: players);
              previousGameOnTap(context, gameArguments: gameArgs);
            },
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Text _getHeadingText({required Game game, required List<Player> players, required String uid}) {
    if (game.gameStatus == GameStatus.finished) {
      return const Text('Game with:', textAlign: TextAlign.left);
    } else if (game.gameStatus == GameStatus.abandoned) {
      return const Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return const Text('Game in progress', textAlign: TextAlign.left);
    }
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required List<Player> players, required String uid}) {
    List<Player> otherPlayers = players.where((player) => player.playerId != uid).toList();
    return Column(
      children: <Widget>[
        ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: otherPlayers.length,
          itemBuilder: (context, index) => _buildPlayerItem(context, game: game, player: otherPlayers[index]),
        ),
      ],
    );
  }

  Widget _buildPlayerItem(BuildContext context, {required Game game, required Player player}) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 16.0,
          child: game.creatorId == player.playerId ? const Text('*') : null,
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 0.0,
            top: 4.0,
            bottom: 4.0,
          ),
          child: Text(player.user!.displayName!),
        ),
        Expanded(
          child: Container(
            child: _buildPlayerScore(game: game, player: player),
          ),
        )
      ],
    );
  }

  Widget _buildPlayerScore({required Game game, required Player player}) {
    PlayerStatus playerStatus = game.playerUids[player.playerId] as PlayerStatus;
    switch (playerStatus) {
      case PlayerStatus.invited:
      case PlayerStatus.accepted:
        return const Text('-', textAlign: TextAlign.right);
      case PlayerStatus.declined:
        return const Text('Declined', textAlign: TextAlign.right);
      case PlayerStatus.resigned:
        return const Text('Resigned', textAlign: TextAlign.right);
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

      String points = myScore == 1 ? 'point' : 'points';
      if (game.gameStatus == GameStatus.finished) {
        if (myScore > highestScore) {
          return Text('You won with $myScore $points');
        } else if (myScore == highestScore) {
          return Text('You drew with $myScore $points');
        } else {
          return Text('You lost with $myScore $points');
        }
      } else {
        return Text('You scored $myScore $points');
      }
    } else {
      return const EmptyContent();
    }
  }
}
