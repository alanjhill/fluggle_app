import 'package:fluggle_app/widgets/list_items_builder.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/pages/play_game/play_game_item.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayGameList extends ConsumerWidget {
  const PlayGameList({
    Key? key,
    required this.data,
    required this.leftSwipeGame,
  }) : super(key: key);

  final AsyncValue<List<Game>> data;
  final Function leftSwipeGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;

    return SafeArea(
      child: ListItemsBuilder<Game>(
        padding: const EdgeInsets.all(0.0),
        physics: const ScrollPhysics(),
        data: data,
        itemBuilder: (context, game) => PlayGameItem(
          game: game,
          uid: user.uid,
          leftSwipeGame: leftSwipeGame,
        ),
      ),
    );
  }
}
