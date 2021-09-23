import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/game/game_page.dart';
import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/utils/utils.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StartGamePage extends ConsumerStatefulWidget {
  final StartGameArguments startGameArguments;
  StartGamePage({required this.startGameArguments});

  @override
  _StartGamePageState createState() => _StartGamePageState();
}

class _StartGamePageState extends ConsumerState<StartGamePage> {
  List<AppUser>? players;
  final List<int> _values = [60, 120, 180];
  int _currentValue = 60;
  final List<bool> _selections = List.generate(3, (_) => false);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        players = widget.startGameArguments.players;
      });
    });
    _selections[0] = true;
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = CustomAppBar(
      titleText: players != null && players!.isNotEmpty ? Strings.newGame : Strings.practiceGame,
    );
    //final List<AppUser> players = widget.startGameArguments.players;

    return Scaffold(
        appBar: appBar,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Column(children: <Widget>[
                ReusableCard(
                  key: Key(''),
                  cardChild: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildTitle(players),
                      SizedBox(height: 4),
                      ..._buildPlayerList(players),
                      _buildGameDuration(context),
                      SizedBox(height: 4),
                      _buildPlayButton(context, ref),
                      //_getHeadingText(),
                      //..._buildPlayerList(players),
                    ],
                  ),
                ),
              ]),
            );
          },
        ));
  }

  Widget _buildTitle(List<AppUser>? players) {
    if (players != null && players.isNotEmpty) {
      return Text('Play a game with:');
    } else {
      return Text('Practice Game');
    }
  }

  List<Widget> _buildPlayerList(List<AppUser>? players) {
    List<Widget> playerList = [];
    if (players != null) {
      for (var player in players) {
        playerList.add(_buildPlayerItem(player: player));
      }
    }

    return playerList;
  }

  Widget _buildPlayerItem({required AppUser player}) {
    return Container(
      padding: EdgeInsets.all(0),
      //color: Colors.red,
      child: Padding(
        key: ValueKey(player.uid),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        child: ListTile(
          contentPadding: EdgeInsets.all(0),
          visualDensity: VisualDensity.compact,
          title: Text(player.displayName!),
          //subtitle: Text('id: ${player.uid}'),
        ),
      ),
    );
  }

  void _createGame(BuildContext context, WidgetRef ref) async {
    final gameService = ref.read(gameServiceProvider);
    // Create game and wait for other players to join...
    if (players!.isNotEmpty) {
      List<Player> gamePlayers = gameService.createPlayersFromAppUsers(ref, appUsers: players!);
      Map<String, PlayerStatus> playerUids = {};

      for (var gamePlayer in gamePlayers) {
        playerUids[gamePlayer.playerId] = PlayerStatus.invited;
      }

      Game game = await gameService.createGame(ref, gameStatus: GameStatus.created, players: gamePlayers, playerUids: playerUids, gameTime: _currentValue);
      debugPrint('game: $game');

      GameArguments gameArgs = GameArguments(game: game, players: gamePlayers);
      Navigator.of(context).pushNamed(AppRoutes.gamePage, arguments: gameArgs);
    } else {
      // Game
      List<Player> players = [];
      Game game = gameService.createPracticeGame(ref, players: players, gameTime: _currentValue);

      // Game Page
      Navigator.of(context).pushNamed(AppRoutes.gamePage, arguments: GameArguments(game: game, players: players));
    }
  }

  Widget _buildGameDuration(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                'Time:',
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: Container(
                //width: constraints.maxWidth - 80,
                padding: const EdgeInsets.all(0.0),
                margin: const EdgeInsets.all(0.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return ToggleButtons(
                      //spacing: 0.0,
                      constraints: BoxConstraints(
                        maxWidth: (constraints.maxWidth / 3),
                      ),
                      renderBorder: false,
                      children: <Widget>[
                        _buildTimeSelection(
                          selected: _selections[0],
                          text: Utils.secondsToMinutes(_values[0]),
                          maxWidth: constraints.maxWidth / 3,
                        ),
                        _buildTimeSelection(
                          selected: _selections[1],
                          text: Utils.secondsToMinutes(_values[1]),
                          maxWidth: constraints.maxWidth / 3,
                        ),
                        _buildTimeSelection(
                          selected: _selections[2],
                          text: Utils.secondsToMinutes(_values[2]),
                          maxWidth: constraints.maxWidth / 3,
                        ),
                      ],
                      isSelected: _selections,
                      onPressed: (int index) {
                        setState(() {
                          _resetSelections();
                          _selections[index] = !_selections[index];
                          _currentValue = _values[index];
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeSelection({required String text, required bool selected, required double maxWidth}) {
    return Container(
      width: maxWidth - 16,
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.transparent,
        border: Border.all(
          width: 1.0,
          color: selected ? Colors.white : kFluggleLightColor,
        ),
      ),
      child: SizedBox(
        height: 24.0,
        child: AutoSizeText(
          text,
          textAlign: TextAlign.center,
          overflow: TextOverflow.clip,
          style: TextStyle(
            fontSize: 40,
            color: selected ? Colors.white : kFluggleLightColor,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  void _resetSelections() {
    for (int counter = 0; counter < _selections.length; counter++) {
      _selections[counter] = false;
    }
  }

  String _getGameTimeLabel(int sec) {
    var minutes = sec / 60;
    var seconds = sec % 60;
    return '${minutes.toInt().toString().padLeft(1, "0")}:${seconds.toInt().toString().padLeft(2, "0")}';
  }

  Widget _buildPlayButton(BuildContext context, WidgetRef ref) {
    return CustomRaisedButton(
      onPressed: () => _createGame(context, ref),
      child: Text('Play'),
    );
  }
}

class StartGameArguments {
  final List<AppUser> players;
  StartGameArguments({required this.players});
}
