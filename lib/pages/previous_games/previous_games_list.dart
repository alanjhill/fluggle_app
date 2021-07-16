import 'package:fluggle_app/common_widgets/list_items_builder.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_item.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviousGamesList extends StatelessWidget {
  PreviousGamesList({Key? key, required this.data, required this.previousGameOnTap}) : super(key: key);

  final AsyncValue<List<Game>> data;
  final Function previousGameOnTap;

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser!;

    return ListItemsBuilder<Game>(
      physics: ScrollPhysics(),
      data: data,
      itemBuilder: (context, game) => PreviousGamesItem(
        game: game,
        uid: user.uid,
        previousGameOnTap: previousGameOnTap,
      ),
    );
  }
}
