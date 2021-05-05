import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/screens/scores/scores_screen.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:flutter_swipe_action_cell/core/controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PreviousGamesItem extends StatefulWidget {
  final Game game;
  final String uid;

  PreviousGamesItem({required this.game, required this.uid});

  @override
  _PreviousGamesItemState createState() => _PreviousGamesItemState();
}

class _PreviousGamesItemState extends State<PreviousGamesItem> {
  SwipeActionController? controller;

  @override
  void initState() {
    super.initState();
    controller = SwipeActionController(selectedIndexPathsChangeCallback: (changedIndexPaths, selected, currentCount) {
      debugPrint('cell at ${changedIndexPaths.toString()} is/are ${selected ? 'selected' : 'unselected'} ,current selected count is $currentCount');
    });
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
          _ganeScoreButtonPressed(context, game: widget.game);
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(0.0),
              itemCount: playerList.length,
              itemBuilder: (context, index) {
                Player player = playerList[index];
                return _buildPlayerItem(
                  player: player,
                );
              },
            ),
            _getGameWinner(playerList: playerList)
          ],
        ));

    return playerListWidget;
  }

  Widget _buildPlayerItem({required Player player}) {
    return Row(children: <Widget>[
      Container(
        padding: EdgeInsets.only(
          left: 16.0,
          top: 8.0,
          bottom: 8.0,
        ),
        child: Text('${player.user?.displayName}'),
      ),
    ]
/*      tileColor: Colors.red,
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.only(left: 16),
      title:
      trailing: Container(
        width: 50,
        child: _getPlayerStatusIcon(player: player),
      ),*/
        );
  }

  Widget _buildPlayers(BuildContext context, {required Game game, required String uid}) {
    final viewModel = Provider.of<GameViewModel>(context, listen: false);
    return StreamBuilder<List<Player>>(
      stream: viewModel.gamePlayersStream(gameId: game.gameId!),
      builder: (_, snapshot) {
        //debugPrint('snapshot: $snapshot');
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
          ),
        );
      },
    );
  }

  Widget _getPlayerStatusIcon({required Player player}) {
    if (player.status == PlayerStatus.invited) {
      return Icon(Icons.watch_later_outlined);
    } else if (player.status == PlayerStatus.accepted) {
      return Icon(Icons.done);
    } else if (player.status == PlayerStatus.declined) {
      return Icon(Icons.close);
    } else if (player.status == PlayerStatus.resigned) {
      return Icon(Icons.close);
    } else {
      return Container();
    }
  }
}
