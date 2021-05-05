import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';

class GameAndPlayers {
  final Game game;
  List<Player> players;

  GameAndPlayers({required this.game, required this.players});
}
