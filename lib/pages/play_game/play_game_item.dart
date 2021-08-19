import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/widgets/list_items_builder.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/play_game/play_game_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/utils/utils.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PlayGameItem extends ConsumerWidget {
  final Game game;
  final String? uid;
  final Function leftSwipeGame;
  PlayGameItem({
    required this.game,
    this.uid,
    required this.leftSwipeGame,
  });

  void _playGameButtonPressed(BuildContext context, {required Game game}) {
    Navigator.of(context).pushNamed(AppRoutes.gamePage, arguments: game);
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final playersAsyncValue = watch(playerStreamProvider(game.gameId!));

    return Slidable(
      key: Key(game.gameId!),
      actionPane: SlidableBehindActionPane(),
      child: Container(
        child: GestureDetector(
          child: ReusableCard(
            key: Key(game.gameId!),
            cardChild: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _getHeadingText(game: game, uid: uid!),
                  _buildPlayers(context, uid: uid!, game: game, playerData: playersAsyncValue),
                  _buildGameDuration(context, game: game),
                  //Text(game.gameId!),
                ],
              ),
            ),
          ),
          onTap: () {
            _playGameButtonPressed(context, game: game);
          },
        ),
      ),
      movementDuration: Duration(milliseconds: 500),
      secondaryActions: [
        IconSlideAction(
          icon: game.creatorId == uid ? Icons.delete : Icons.close,
          onTap: () async {
            debugPrint('SwipeAction -> onTap');
            await leftSwipeGame(context, game: game, uid: uid);
          },
          color: Colors.transparent,
        ),
      ],
    );
  }

  Text _getHeadingText({required Game game, required String uid}) {
    if (game.gameStatus == GameStatus.created) {
      if (uid == game.creatorId) {
        return Text('You invited:', textAlign: TextAlign.left);
      } else {
        return Text('Game invite', textAlign: TextAlign.left);
      }
    } else if (game.gameStatus == GameStatus.abandoned) {
      return Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return Text('Game complete', textAlign: TextAlign.left);
    }
  }

  Widget _buildPlayerItem(BuildContext context, {required Game game, required Player player}) {
    return Container(
      //color: kFluggleBoardBackgroundColor,
      //height: 128.0,
      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.all(0.0),
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
              child: AutoSizeText(player.user!.displayName!),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 8.0),
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
        return Text('');
      case PlayerStatus.declined:
        return AutoSizeText('Declined', textAlign: TextAlign.right);
      case PlayerStatus.resigned:
        return AutoSizeText('Resigned', textAlign: TextAlign.right);
      case PlayerStatus.finished:
        return AutoSizeText('Finished');
    }
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required playerData, required String uid}) {
    return Column(
      children: <Widget>[
        ListItemsBuilder<Player>(
          padding: EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          data: playerData,
          itemBuilder: (context, player) => _buildPlayerItem(context, game: game, player: player),
        ),
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
