import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game/game_view_model.dart';
import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/screens/scores/scores_item.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

class ScoresList extends StatefulWidget {
  final String uid;
  final String gameId;

  ScoresList({required this.uid, required this.gameId});

  static Widget create(BuildContext context, {required String gameId}) {
    final database = Provider.of<FirestoreDatabase>(context, listen: false);
    return Provider<GameViewModel>(
      create: (_) => GameViewModel(database: database),
      child: ScoresList(uid: database.uid, gameId: gameId),
    );
  }

  @override
  _ScoresListState createState() => _ScoresListState();
}

class _ScoresListState extends State<ScoresList> {
  GameService gameService = GameService();

  static LinkedScrollControllerGroup? _verticalControllersGroup = LinkedScrollControllerGroup();
  static List<ScrollController> _verticalScrollControllers = [];

  LinkedScrollControllerGroup? _horizontalControllersGroup = LinkedScrollControllerGroup();
  List<ScrollController> _horizontalScrollControllers = [];

  @override
  void initState() {
    super.initState();
    _horizontalScrollControllers.add(_horizontalControllersGroup!.addAndGet());
    _horizontalScrollControllers.add(_horizontalControllersGroup!.addAndGet());
    _horizontalScrollControllers.add(_horizontalControllersGroup!.addAndGet());
  }

  @override
  void dispose() {
    super.dispose();
    _verticalScrollControllers.forEach((ScrollController scrollController) {
      //scrollController.dispose();
    });

    _horizontalScrollControllers.forEach((ScrollController scrollController) {
      //scrollController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        height: constraints.maxHeight,
        decoration: BoxDecoration(
          color: kFlugglePrimaryColor,
          border: Border.all(
            color: kFlugglePrimaryColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.0),
          //boxShadow: [const BoxShadow(color: Colors.black, spreadRadius: -2, blurRadius: 2)],
        ),
        child: _build(context),
      );
    });
  }

  Widget _build(BuildContext context) {
    final viewModel = Provider.of<GameViewModel>(context, listen: false);
    return StreamBuilder<List<Player>>(
      stream: viewModel.gamePlayersStream(gameId: widget.gameId, includeSelf: true),
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

          // Scores
          return _buildScores(context, snapshot.data);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildScores(BuildContext context, playerList) {
    final mediaQuery = MediaQuery.of(context);
    // Tally of all words
    Map<String, int> wordTally = {};

    // Process the scores/words
    gameService.processWords(context, gameId: widget.gameId, playerList: playerList, wordTally: wordTally);

    // Add two scrollControllers
    playerList.forEach((_) {
      _verticalScrollControllers.add(_verticalControllersGroup!.addAndGet());
    });

    final double bannerHeight = 48.0;
    final double headerHeight = 36.0;
    final double footerHeight = 96.0;

    return Container(
      color: kFluggleBoardBackgroundColor,
      padding: EdgeInsets.all(0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          debugPrint('_buildScores, constraints: ${constraints.toString()}');
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildScoresBanner(
                context,
                playerList: playerList,
                height: bannerHeight,
              ),
              _buildPlayersScoresHeader(
                context,
                playerList: playerList,
                height: headerHeight,
                scrollerIndex: 0,
              ),
              _buildPlayersScores(
                context,
                playerList: playerList,
                wordTally: wordTally,
                height: constraints.maxHeight - bannerHeight - headerHeight - footerHeight,
                scrollerIndex: 1,
              ),
              _buildPlayersScoresFooter(
                context,
                playerList: playerList,
                height: footerHeight,
                scrollerIndex: 2,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoresBanner(BuildContext context, {required double height, required List<Player> playerList}) {
    List<Player> winningPlayers = [];

    int maxScore = 0;
    playerList.forEach((Player player) {
      if (winningPlayers.length == 0) {
        winningPlayers.add(player);
        maxScore = player.score;
      } else {
        if (player.score == maxScore) {
          winningPlayers.add(player);
        } else if (player.score > maxScore) {
          winningPlayers.clear();
          winningPlayers.add(player);
          maxScore = player.score;
        }
      }
    });

    if (winningPlayers.length == 1) {
      // Winner
      return Text('${winningPlayers[0].user!.displayName} WON!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
    } else {
      // DRAW
      return Text('It\'s a DRAW!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24.0));
    }
  }

  Widget _buildPlayersScoresHeader(BuildContext context, {required double height, required List<Player> playerList, required int scrollerIndex}) {
    return Container(
      padding: EdgeInsets.all(0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: height,
                  child: NotificationListener<ScrollEndNotification>(
                      child: ListView.builder(
                        controller: _horizontalScrollControllers[scrollerIndex],
                        scrollDirection: Axis.horizontal,
                        itemCount: playerList.length,
                        itemBuilder: (context, index) {
                          Player player = playerList[index];
                          return Container(
                            margin: EdgeInsets.only(left: 4, right: 4),
                            width: constraints.maxWidth / 2 - 8,
                            child: Text(
                              '${player.user!.displayName}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        },
                      ),
                      onNotification: (scrollEnd) =>
                          _scrollEndNotification(scrollMetrics: scrollEnd.metrics, width: constraints.maxWidth, scrollerIndex: scrollerIndex)),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayersScores(BuildContext context,
      {required List<Player> playerList, required Map<String, int> wordTally, required double height, required int scrollerIndex}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: height,
          width: constraints.maxWidth,
          child: NotificationListener<ScrollEndNotification>(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _horizontalScrollControllers[1],
                scrollDirection: Axis.horizontal,
                itemCount: playerList.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: height,
                    margin: EdgeInsets.only(left: 4, right: 4, bottom: 4),
                    padding: EdgeInsets.only(bottom: 2),
                    width: constraints.maxWidth / 2 - 8,
                    decoration: BoxDecoration(
                      color: kFluggleBoardBackgroundColor,
                      border: Border.all(width: 1.0, color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: _buildPlayerScoresList(
                      context,
                      playerList: playerList,
                      index: index,
                      wordTally: wordTally,
                      scrollControllers: _verticalScrollControllers,
                    ),
                  );
                },
              ),
              onNotification: (scrollEnd) =>
                  _scrollEndNotification(scrollMetrics: scrollEnd.metrics, width: constraints.maxWidth, scrollerIndex: scrollerIndex)),
        );
      },
    );
  }

  Widget _buildPlayerScoresList(BuildContext context,
      {required List<Player> playerList, required int index, required Map<String, int> wordTally, required List<ScrollController> scrollControllers}) {
    final mediaQuery = MediaQuery.of(context);
    final double width = mediaQuery.size.width;
    debugPrint('width: ${width}');

    final double borderWidth = 2.0;
    final double headerHeight = 24.0;

    final Player player = playerList[index];

    if (playerList[index].status == PlayerStatus.finished) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            child: ListView.builder(
              controller: _verticalScrollControllers[index],
              itemCount: wordTally.length,
              itemBuilder: (context, index) {
                if (player.status == PlayerStatus.finished) {
                  String word = wordTally.keys.elementAt(index);
                  if (player.words![word] != null) {
                    return _buildPlayerScoreItem(context, playerWord: player.words![word]!);
                  } else {
                    return _buildPlayerScoreItem(context, playerWord: PlayerWord(gameWord: GameWord(word: word, score: 0, unique: null), gridItems: []));
                  }
                } else {
                  return Container(
                    height: 24,
                    child: Text(
                      'Waiting...',
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    } else {
      return Container(
        height: 24,
        child: Text(
          'Waiting...',
        ),
      );
    }
  }

  Widget _buildPlayerScoreItem(BuildContext context, {required PlayerWord playerWord}) {
    return ScoresItem(playerWord: playerWord);
  }

  Widget _buildPlayersScoresFooter(BuildContext context, {required double height, required List<Player> playerList, required int scrollerIndex}) {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                  height: height,
                  child: NotificationListener<ScrollEndNotification>(
                      child: ListView.builder(
                        controller: _horizontalScrollControllers[2],
                        scrollDirection: Axis.horizontal,
                        itemCount: playerList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(left: 4, right: 4),
                            padding: EdgeInsets.only(left: 4.0, right: 4.0),
                            height: 100,
                            width: constraints.maxWidth / 2 - 8,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _score(player: playerList[index]),
                                ..._wordCounts(player: playerList[index]),
                              ],
                            ),
                          );
                        },
                      ),
                      onNotification: (scrollEnd) =>
                          _scrollEndNotification(scrollMetrics: scrollEnd.metrics, width: constraints.maxWidth, scrollerIndex: scrollerIndex)),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _score({required Player player}) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Text(
              'Score',
              textAlign: TextAlign.left,
            ),
          ),
          Text(
            '${player.score}',
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  /// Total Words and Unique Words
  List<Widget> _wordCounts({required Player player}) {
    int wordCount = 0;
    int uniqueWordCount = 0;

    player.words!.forEach((String word, PlayerWord playerWord) {
      wordCount++;
      if (playerWord.gameWord.unique! == true) {
        uniqueWordCount++;
      }
    });

    List<Widget> rows = [];

    // Total Words
    rows.add(
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(child: Text('Total words:', textAlign: TextAlign.left)),
            Text('${wordCount}', textAlign: TextAlign.right),
          ],
        ),
      ),
    );

    // Unique Words
    rows.add(
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(child: Text('Unique words:', textAlign: TextAlign.left)),
            Text('${uniqueWordCount}', textAlign: TextAlign.right),
          ],
        ),
      ),
    );

    return rows;
  }

  double _getNearestPosition({required double width, required double position}) {
    debugPrint('(width / 2) - position: ${(width / 2) - position}, position: ${position}');
    if ((width / 2) - position > position) {
      return 0;
    } else {
      return (width / 2);
    }
  }

  bool _scrollEndNotification({required ScrollMetrics scrollMetrics, required double width, required int scrollerIndex}) {
    Future.delayed(Duration(milliseconds: 0), () {
      double _position = _getNearestPosition(width: width, position: scrollMetrics.pixels);
      _horizontalScrollControllers.asMap().forEach((int index, ScrollController scrollController) {
        if (index != scrollerIndex) {
          scrollController.animateTo(_position, duration: Duration(milliseconds: 500), curve: Curves.ease);
        }
      });
    });
    return true;
  }
}
