import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/screens/play_game/play_game_item.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayGameList extends StatelessWidget {
  final String uid;
  PlayGameList({required this.uid});

  static Widget create(BuildContext context) {
    final database = Provider.of<FirestoreDatabase>(context, listen: false);
    return Provider<GameViewModel>(
      create: (_) => GameViewModel(database: database),
      child: PlayGameList(uid: database.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context, listen: false);
    return StreamBuilder<List<Game>>(
      stream: viewModel.pendingGamesStream(),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final games = snapshot.data;
          if (games == null) {
            return Container();
          }

          return _buildGamesList(context, snapshot.data);
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

  Widget _buildGamesList(BuildContext context, games) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) => _buildPlayGameItem(
        context,
        game: games[index],
        uid: uid,
      ),
    );
  }

  Widget _buildPlayGameItem(BuildContext context, {required Game game, required String uid}) {
    return PlayGameItem(game: game, uid: uid);
  }
}
