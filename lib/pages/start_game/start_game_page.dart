import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';

class StartGamePage extends StatefulWidget {
  final StartGameArguments startGameArguments;
  StartGamePage({required this.startGameArguments});

  @override
  _StartGamePageState createState() => _StartGamePageState();
}

class _StartGamePageState extends State<StartGamePage> {
  final GameService gameService = GameService();
  List<AppUser>? players;

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = CustomAppBar(title: Text(Strings.startGamePage));
    final List<AppUser> players = widget.startGameArguments.players;

    return Scaffold(
        appBar: appBar,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(children: <Widget>[
                  SwipeActionCell(
                    key: Key(''),
                    child: GestureDetector(
                      child: ReusableCard(
                        key: Key(''),
                        cardChild: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text('Play a game with:'),
                            ..._buildPlayerList(players),
                            _buildStartButton(context),
                            //_getHeadingText(),
                            //..._buildPlayerList(players),
                          ],
                        ),
                      ),
                      onTap: () {
                        debugPrint('card tapped');
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
                  ),
                ]),
              ),
            );
          },
        ));
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        players = widget.startGameArguments.players;
      });
    });
    super.initState();
  }

  List<Widget> _buildPlayerList(List<AppUser> players) {
    List<Widget> playerList = [];
    for (var player in players) {
      playerList.add(_buildPlayerItem(player: player));
    }

    return playerList;
  }

  Widget _buildPlayerItem({required AppUser player}) {
    return Padding(
      key: ValueKey(player.uid),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(player.displayName),
        //subtitle: Text('id: ${player.uid}'),
      ),
    );
  }

  void _createGame(BuildContext context) async {
    // Create game and wait for other players to join...
    debugPrint("Create Game");
    Game game = await gameService.createGame(context, gameStatus: GameStatus.created, players: players);
    debugPrint('game: $game');
    Navigator.of(context).pushNamed(AppRoutes.gamePage, arguments: game);
  }

  Widget _buildStartButton(BuildContext context) {
    return CustomRaisedButton(
      onPressed: () => _createGame(context),
      child: Text('Go'),
    );
  }
}

class StartGameArguments {
  final List<AppUser> players;
  StartGameArguments({required this.players});
}
