import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:flutter/material.dart';

class ScoresHeader extends StatelessWidget {
  ScoresHeader({
    required this.context,
    required this.game,
    required this.player,
    required this.height,
    required this.width,
    required this.index,
    required this.scrollController,
  });

  final BuildContext context;
  final Game game;
  final Player player;
  final double height;
  final double width;
  final int index;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (game.practice == true) {
      return Container();
    } else {
      if (index == 0) {
        return Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(0),
          child: _playerScoresHeaderContent(
            player: player,
            height: height,
            width: width,
            first: true,
          ),
        );
      } else {
        return Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(0),
          child: _playerScoresHeaderContent(
            player: player,
            height: height,
            width: width,
            first: true,
          ),
        );
      }
    }
  }

  Widget _playerScoresHeaderContent({
    required Player player,
    required double height,
    required double width,
    required bool first,
  }) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(left: kScoresColumnPadding, right: kScoresColumnPadding),
      padding: EdgeInsets.only(left: kScoresColumnPadding, right: kScoresColumnPadding),
      child: AutoSizeText(
        player.user!.displayName!,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
        maxLines: 1,
      ),
    );
  }
}
