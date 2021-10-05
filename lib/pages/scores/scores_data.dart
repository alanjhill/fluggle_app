import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/pages/scores/scores.dart';
import 'package:fluggle_app/pages/scores/scores_footer.dart';
import 'package:fluggle_app/pages/scores/scores_header.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:fluggle_app/pages/scores/scroll_utils.dart';

class ScoresData extends StatefulWidget {
  const ScoresData({
    Key? key,
    required this.game,
    required this.players,
    required this.uid,
    required this.wordTally,
    required this.height,
    required this.width,
  }) : super(key: key);

  final Game game;
  final List<Player> players;
  final String uid;
  final double height;
  final double width;
  final Map<String, int> wordTally;

  @override
  _ScoresDataState createState() => _ScoresDataState();
}

class _ScoresDataState extends State<ScoresData> {
  final double headerHeight = 36.0;
  final double footerHeight = 96.0;

  late LinkedScrollControllerGroup _controllers;
  late ScrollController _firstColumnController;
  late ScrollController _otherColumnController;

  static final LinkedScrollControllerGroup? _verticalControllersGroup =
      LinkedScrollControllerGroup();
  static List<ScrollController> _verticalScrollControllers = [];

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _firstColumnController = _controllers.addAndGet();
    _otherColumnController = _controllers.addAndGet();
    for (var _ in widget.players) {
      _verticalScrollControllers.add(_verticalControllersGroup!.addAndGet());
    }
  }

  @override
  void dispose() {
    debugPrint('>>> ScoredData.dispose()');
    super.dispose();
    _firstColumnController.dispose();
    _otherColumnController.dispose();
    _verticalScrollControllers = [];
    for (var scrollController in _verticalScrollControllers) {
      scrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    int thisPlayerIndex =
        widget.players.indexWhere((player) => widget.uid == player.playerId);
    Player thisPlayer = widget.players.elementAt(thisPlayerIndex);

    List<Player> otherPlayers = [];
    if (widget.players.isNotEmpty) {
      for (var player in widget.players) {
        if (player.playerId != thisPlayer.playerId) {
          otherPlayers.add(player);
        }
      }
    }

    // For single player practice, scores is full width, otherwise, half width
    final scoresWidgetWidth =
        otherPlayers.isEmpty ? widget.width : widget.width / 2;
    return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Row(children: <Widget>[
          Column(children: <Widget>[
            ScoresHeader(
              context: context,
              game: widget.game,
              player: thisPlayer,
              height: headerHeight,
              width: scoresWidgetWidth,
              index: 0,
              scrollController: _firstColumnController,
            ),
            Scores(
              context: context,
              game: widget.game,
              player: thisPlayer,
              wordTally: widget.wordTally,
              height: widget.height - headerHeight - footerHeight,
              width: scoresWidgetWidth,
              verticalScrollController: _verticalScrollControllers[0],
              index: 0,
              first: true,
            ),
            ScoresFooter(
              context: context,
              game: widget.game,
              player: thisPlayer,
              height: footerHeight,
              width: scoresWidgetWidth,
              index: 0,
              scrollController: _firstColumnController,
            ),
          ]),
          otherPlayers.isNotEmpty
              ? SizedBox(
                  height: widget.height,
                  width: widget.width / 2,
                  child: NotificationListener<ScrollEndNotification>(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        controller: _otherColumnController,
                        itemCount: otherPlayers.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              ScoresHeader(
                                context: context,
                                game: widget.game,
                                player: otherPlayers[index],
                                height: headerHeight,
                                width: scoresWidgetWidth,
                                index: index,
                                scrollController: _otherColumnController,
                              ),
                              Scores(
                                context: context,
                                game: widget.game,
                                player: otherPlayers[index],
                                wordTally: widget.wordTally,
                                height:
                                    widget.height - headerHeight - footerHeight,
                                width: scoresWidgetWidth,
                                verticalScrollController:
                                    _verticalScrollControllers[index + 1],
                                index: index,
                                first: false,
                              ),
                              ScoresFooter(
                                context: context,
                                game: widget.game,
                                player: otherPlayers[index],
                                height: footerHeight,
                                width: scoresWidgetWidth,
                                index: index,
                                scrollController: _otherColumnController,
                              ),
                            ],
                          );
                        },
                      ),
                      onNotification: (scrollEnd) {
                        ScrollUtils.scrollEndNotification(
                          scrollMetrics: scrollEnd.metrics,
                          width: widget.width / 2,
                          itemCount: otherPlayers.length,
                          scrollController: _otherColumnController,
                        );
                        return true;
                      }),
                )
              : Container(),
        ]));
  }
}
