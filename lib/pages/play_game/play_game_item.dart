import 'package:fluggle_app/common_widgets/list_items_builder.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/play_game/play_game_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class PlayGameItem extends ConsumerWidget {
  final Game game;
  final String? uid;
  PlayGameItem({
    required this.game,
    this.uid,
  });

  void _playGameButtonPressed(BuildContext context, {required Game game}) {
    Navigator.of(context).pushNamed(AppRoutes.gamePage, arguments: game);
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final playersAsyncValue = watch(playerStreamProvider(game.gameId!));

    return SwipeActionCell(
      key: Key(game.gameId!),
      child: GestureDetector(
        child: ReusableCard(
          key: Key('${game.gameId}'),
          cardChild: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _getHeadingText(game: game, uid: uid!),
                _buildPlayers(context, uid: uid!, game: game, playerData: playersAsyncValue),
              ],
            ),
          ),
        ),
        onTap: () {
          _playGameButtonPressed(context, game: game);
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
    if (game.gameStatus == GameStatus.created) {
      if (uid == game.creatorId) {
        return Text('Waiting to play with:', textAlign: TextAlign.left);
      } else {
        return Text('Invited you to play', textAlign: TextAlign.left);
      }
    } else if (game.gameStatus == GameStatus.abandoned) {
      return Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return Text('Game complete', textAlign: TextAlign.left);
    }
  }

  Widget _buildPlayerItem(BuildContext context, {required Game game, required Player player}) {
    return ListTile(
      title: Text('${player.user?.displayName}'),
      trailing: Container(
        margin: EdgeInsets.all(0.0),
        padding: EdgeInsets.all(0.0),
        width: 50,
        child: _getPlayerStatusIcon(context, game: game, player: player),
      ),
    );
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required playerData, required String uid}) {
    //gamePlayersAsyncValue.whenData((list) => doSomething(list) ? debugPrint('1') : debugPrint('2'));

    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[
          ListItemsBuilder<Player>(
            data: playerData,
            itemBuilder: (context, player) => _buildPlayerItem(context, game: game, player: player),
          ),
        ],
      ),
    );
  }

  /// Icon reflecting status of player
  Widget _getPlayerStatusIcon(BuildContext context, {required Game game, required Player player}) {
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
  }
}
