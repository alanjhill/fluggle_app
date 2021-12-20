import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/game/game_page.dart';
import 'package:fluggle_app/pages/play_game/play_game_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/utils/utils.dart';
import 'package:fluggle_app/widgets/list_items_builder.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayGameItem extends ConsumerWidget {
  final Game game;
  final String? uid;
  final Function leftSwipeGame;
  const PlayGameItem({
    Key? key,
    required this.game,
    this.uid,
    required this.leftSwipeGame,
  }) : super(key: key);

  void _playGameButtonPressed(BuildContext context, {required Game game, required List<Player> players}) {
    GameArguments gameArgs = GameArguments(game: game, players: players);
    Navigator.of(context).pushNamed(AppRoutes.gamePage, arguments: gameArgs);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsyncValue = ref.watch(playerStreamProvider(game.gameId!));

    return Dismissible(
      key: Key(game.gameId!),
      direction: DismissDirection.endToStart,
      movementDuration: const Duration(milliseconds: 500),
      background: Container(
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(
          right: 20,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
      ),
      confirmDismiss: (direction) async {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Decline Game Invitation?'),
            content: const Text('Are you sure you want to decline this game?'),
            actions: <Widget>[
              TextButton(
                child: const Text('No'),
                onPressed: () async {
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
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await leftSwipeGame(context, game: game, uid: uid);
        }
      },
      child: GestureDetector(
        child: ReusableCard(
          key: Key(game.gameId!),
          cardChild: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _getHeadingText(game: game, uid: uid!),
              _buildPlayers(context, uid: uid!, game: game, playerData: playersAsyncValue),
              _buildGameDuration(context, game: game),
              Text(game.gameId!),
            ],
          ),
        ),
        onTap: () {
          List<Player> players = [];
          playersAsyncValue.whenData((playersData) {
            players.addAll(playersData);
          });
          _playGameButtonPressed(context, game: game, players: players);
        },
      ),
    );
  }

  Text _getHeadingText({required Game game, required String uid}) {
    if (game.gameStatus == GameStatus.created) {
      if (uid == game.creatorId) {
        return const Text('You invited:', textAlign: TextAlign.left);
      } else {
        return const Text('Game invite', textAlign: TextAlign.left);
      }
    } else if (game.gameStatus == GameStatus.abandoned) {
      return const Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return const Text('Game complete', textAlign: TextAlign.left);
    }
  }

  Widget _buildPlayerItem(BuildContext context, {required Game game, required Player player}) {
    return Container(
      //color: kFluggleBoardBackgroundColor,
      //height: 128.0,
      padding: const EdgeInsets.all(0.0),
      margin: const EdgeInsets.all(0.0),
      child: Row(
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
            child: AutoSizeText(player.user!.displayName!),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildPlayerStatus(game: game, player: player),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerStatus({required Game game, required Player player}) {
    PlayerStatus playerStatus = game.playerUids[player.playerId] as PlayerStatus;
    switch (playerStatus) {
      case PlayerStatus.invited:
      case PlayerStatus.accepted:
        return const Text('');
      case PlayerStatus.declined:
        return const AutoSizeText('Declined', textAlign: TextAlign.right);
      case PlayerStatus.resigned:
        return const AutoSizeText('Resigned', textAlign: TextAlign.right);
      case PlayerStatus.finished:
        return const AutoSizeText('Finished');
    }
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required playerData, required String uid}) {
    return Column(
      children: <Widget>[
        ListItemsBuilder<Player>(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            data: playerData,
            itemBuilder: (context, player) {
              if (player.playerId != uid) {
                return _buildPlayerItem(context, game: game, player: player);
              } else {
                return Container();
              }
            }),
      ],
    );
  }

  /// Icon reflecting status of player
/*  Widget _getPlayerStatusIcon(BuildContext context, {required Game game, required Player player}) {
    if (player.playerStatus == PlayerStatus.invited) {
      return Icon(Icons.watch_later_outlined, color: Theme.of(context).iconTheme.color);
    } else if (player.playerStatus == PlayerStatus.accepted) {
      return Icon(Icons.done, color: Theme.of(context).iconTheme.color);
    } else if (player.playerStatus == PlayerStatus.declined) {
      return Icon(Icons.close, color: Theme.of(context).iconTheme.color);
    } else if (player.playerStatus == PlayerStatus.resigned) {
      return Icon(Icons.close, color: Theme.of(context).iconTheme.color);
    } else {
      return Container();
    }
  }*/

  Widget _buildGameDuration(BuildContext context, {required Game game}) {
    return Text('Time: ${Utils.secondsToMinutes(game.gameTime)}');
  }
}
