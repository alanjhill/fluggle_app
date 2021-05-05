import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*class StartGameScreenBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Player UID
    var player = args.user;

    // Game
    Game? game;

    gameService.createGame(context, playerUid: player.uid).then((Game g) {
      game = g;

      return StartGameScreen._(
        title: Strings.appName,
        game: game,
      );
    });

    return Center(child: CircularProgressIndicator());
  }
}*/

class StartGameScreen extends StatefulWidget {
  static const String routeName = "start-game";
  final StartGameArguments startGameArguments;
  StartGameScreen({required this.startGameArguments});

  @override
  _StartGameScreenState createState() => _StartGameScreenState();
}

class _StartGameScreenState extends State<StartGameScreen> {
  final GameService gameService = GameService();
  List<FluggleUser>? players;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      setState(() {
        players = widget.startGameArguments.players;
      });
    });
    super.initState();
  }

  List<Widget> _buildPlayerList(List<FluggleUser> players) {
    List<Widget> playerList = [];
    players.forEach((FluggleUser player) {
      playerList.add(_buildPlayerItem(player: player));
    });

    return playerList;
  }

  Widget _buildPlayerItem({required FluggleUser player}) {
    return Padding(
      key: ValueKey(player.uid),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(player.displayName),
          subtitle: Text('id: ${player.uid}'),
        ),
      ),
    );
  }

  void _createGame(BuildContext context) async {
    // Create game and wait for other players to join...
    debugPrint("Create Game");
    Game game = await gameService.createGame(context, gameStatus: GameStatus.created, players: players);
    debugPrint('game: $game');
    Navigator.of(context).pushNamed(GameScreen.routeName, arguments: game);
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _createGame(context),
      child: Text('Go'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<FluggleUser> players = widget.startGameArguments.players;

    return Scaffold(
      appBar: customAppBar(title: Strings.startGame),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Play game with:'),
              ..._buildPlayerList(players),
              _buildStartButton(context),
            ],
          ),
        ),
      ),
    );
  }
}

class StartGameArguments {
  final List<FluggleUser> players;

  StartGameArguments({required this.players});
}
