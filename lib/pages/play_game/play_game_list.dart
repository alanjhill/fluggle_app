import 'package:fluggle_app/common_widgets/list_items_builder.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/pages/play_game/play_game_item.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayGameList extends StatelessWidget {
  PlayGameList({Key? key, required this.data}) : super(key: key);

  final AsyncValue<List<Game>> data;

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;

    return SafeArea(
      child: ListItemsBuilder<Game>(
        physics: ScrollPhysics(),
        data: data,
        itemBuilder: (context, game) => PlayGameItem(
          game: game,
          uid: user.uid,
        ),
      ),
    );
  }
}
