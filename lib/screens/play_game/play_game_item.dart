import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:fluggle_app/screens/scores/scores_screen.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PlayGameItem extends StatefulWidget {
  final Game game;
  final String uid;

  PlayGameItem({required this.game, required this.uid});

  @override
  _PlayGameItemState createState() => _PlayGameItemState();
}

class _PlayGameItemState extends State<PlayGameItem> {
  void _playGameButtonPressed(BuildContext context, {required Game game}) {
    debugPrint('Play Game Button Pressed');
    Navigator.of(context).pushNamed(GameScreen.routeName, arguments: game);
  }

  void _ganeScoreButtonPressed(BuildContext context, {required Game game}) {
    debugPrint('Scores Button Pressed');
    Navigator.of(context).pushNamed(ScoresScreen.routeName, arguments: game);
  }

  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: Key(widget.game.gameId!),
      child: GestureDetector(
        child: ReusableCard(
          key: Key('${widget.game.gameId}'),
          cardChild: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //Text('${widget.game.gameId}'),
              _getHeadingText(game: widget.game, uid: widget.uid),
              _buildPlayers(context, game: widget.game, uid: widget.uid),
              //Text('${DateFormat.E().add_Hm().format(widget.game.created.toDate())}'),
            ],
          ),
        ),
        onTap: () {
          _playGameButtonPressed(context, game: widget.game);
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
        return Text('Wants to play::', textAlign: TextAlign.left);
      }
    } else if (game.gameStatus == GameStatus.abandoned) {
      return Text('Game abandoned', textAlign: TextAlign.left);
    } else {
      return Text('Game complete', textAlign: TextAlign.left);
    }
  }

  Widget _buildPlayerList(BuildContext context, {required List<Player> playerList}) {
    List<bool> playersReady = [];
    try {
      playerList.forEach((Player player) {
        if (player.creator == true) {
          playersReady.add(true);
        } else {
          if (player.status == PlayerStatus.accepted) {
            playersReady.add(true);
          } else if (player.status == PlayerStatus.invited) {
            playersReady.add(false);
          }
        }
      });
    } catch (e) {
      debugPrint("!!!!!");
    }

    bool enabled = !playersReady.contains(false);

    var playerListWidget = SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 0.0),
            itemCount: playerList.length,
            itemBuilder: (context, index) {
              Player player = playerList[index];
              return _buildPlayerItem(
                player: player,
              );
            },
          ),
        ],
      ),
    );

    return playerListWidget;
  }

  Widget _buildPlayerItem({required Player player}) {
    return ListTile(
      title: Text('${player.user?.displayName}'),
      trailing: Container(
        margin: EdgeInsets.all(0.0),
        padding: EdgeInsets.all(0.0),
        width: 50,
        child: _getPlayerStatusIcon(player: player),
      ),
    );
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required String uid}) {
    final viewModel = Provider.of<GameViewModel>(context, listen: false);
    return StreamBuilder<List<Player>>(
      stream: viewModel.gamePlayersStream(gameId: game.gameId!),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.connectionState == ConnectionState.active) {
          List<Player> players = snapshot.data as List<Player>;
          return _buildPlayerList(context, playerList: players);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
            body: Center(
          child: CircularProgressIndicator(),
        ));
      },
    );
  }

  /// Icon reflecting status of player
  Widget _getPlayerStatusIcon({required Player player}) {
    if (player.status == PlayerStatus.invited) {
      return Icon(Icons.watch_later_outlined, color: Theme.of(context).iconTheme.color);
    } else if (player.status == PlayerStatus.accepted) {
      return Icon(Icons.done, color: Theme.of(context).iconTheme.color);
    } else if (player.status == PlayerStatus.declined) {
      return Icon(Icons.close, color: Theme.of(context).iconTheme.color);
    } else if (player.status == PlayerStatus.resigned) {
      return Icon(Icons.close, color: Theme.of(context).iconTheme.color);
    } else {
      return Container();
    }
  }
}
