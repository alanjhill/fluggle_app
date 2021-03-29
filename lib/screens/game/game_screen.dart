import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game_letters.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/screens/scores_screen.dart';
import 'package:fluggle_app/widgets/egg_timer.dart';
import 'package:fluggle_app/screens/game/game_board_widget.dart';
import 'package:fluggle_app/screens/game/game_bottom_widget.dart';
import 'package:fluggle_app/screens/game/game_top_widget.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  static const String routeName = "/game";

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> letters = [];
  List<List<GridItem>> gridItems = [];
  List<GridItem> swipedGridItems = [];
  List<String> addedWords = [];
  String currentWord = "";
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    setupGame();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final PreferredSizeWidget appBar = _buildAppBar(context, quitGame);

    final appBarHeight = appBar.preferredSize.height;
    final gameBoardHeight = screenWidth - kGAME_BOARD_PADDING;
    final remainingHeight = screenHeight - appBarHeight - gameBoardHeight - mediaQuery.padding.top;
    final topPanelHeight = remainingHeight / 4 * 3;

    // Top Panel for entered words, number of words, timer etc
    final gameTopPanel = _buildGameTopPanel(topPanelHeight);

    // Game Board for the grid and letters
    final gameBoard = _buildGameBoard(screenWidth - kGAME_BOARD_PADDING);

    // Bottom Bar
    final gameBoardBottomBar = Container(
      child: GameBottomWidget(
        gameStarted: gameStarted,
        startButtonPressed: startGame,
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          gameTopPanel,
          gameBoard,
          gameBoardBottomBar,
        ],
      ),
    );
  }

  List<String> get _addedWords {
    return addedWords;
  }

  bool _isSwipedGridItem(GridItem gridItem) {
    return swipedGridItems.contains(gridItem);
  }

  List<GridItem> _getSwipedGridItems() {
    return swipedGridItems;
  }

  bool _addSwipedGridItem(GridItem gridItem) {
    bool added = false;
    setState(() {
      currentWord = "";
      GridItem? lastAddedGridItem = swipedGridItems.isNotEmpty ? swipedGridItems.last : null;
      if (!swipedGridItems.contains(gridItem) && (gridItem.isAdjacent(lastAddedGridItem) || _isFirstItem())) {
        swipedGridItems.add(gridItem);
        added = true;
      }
    });
    debugPrint('_addSwipedGridItem, added; ${added}');
    return added;
  }

  bool _isFirstItem() {
    return swipedGridItems.isEmpty;
  }

  void _resetWords() {
    setState(() {
      addedWords.clear();
    });
  }

  void _addWord() {
    String word = "";
    for (GridItem gridItem in swipedGridItems) {
      word += gridItem.letter;
    }

    // Add the word to the list of words if it does not exist
    if (word.length >= 3 && !addedWords.contains(word)) {
      setState(() {
        debugPrint('addWord: ${word}');
        addedWords.add(word);
        debugPrint('currentWord: ${currentWord}');
        debugPrint('words: ${addedWords}');
      });
    }

    // Reset the swiped items
    _resetGridItems();

    currentWord = word;
  }

  void _resetGridItems() {
    swipedGridItems.forEach((GridItem gridItem) {
      setState(() {
        gridItem.swiped = false;
      });
    });
  }

  void _resetSwipedItems() {
    setState(() {
      swipedGridItems = [];
    });
  }

/*  void _swipeAllItems() {
    gridItems.forEach((List<GridItem> gridItemList) {
      gridItemList.forEach((GridItem gridItem) {
        gridItem.swiped = true;
      });
    });
  }

  void _unswipeAllItems() {
    gridItem.forEach((List<GridItem> gridItemList) {
      gridItemList.forEach((GridItem gridItem) {
        gridItem.swiped = false;
      });
    });
  }*/

  void _timerEnded(BuildContext context) {
    debugPrint('timerEnded');
    // Go to scoreboard
    Navigator.of(context).pop(null);
    Navigator.of(context).pushNamed(ScoresScreen.routeName);
  }

  void _confirmQuit(BuildContext context) {
    debugPrint('confirmQuit');
    Navigator.pop(context);
    quitGame(context);
  }

  void _cancelQuit(BuildContext context) {
    debugPrint('cancelQuit');
    Navigator.pop(context);
  }

  void _showQuitGameDialog(BuildContext context) {
    showGeneralDialog(
        barrierLabel: 'x',
        barrierDismissible: true,
        context: context,
        transitionDuration: Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              backgroundColor: kFluggleCubeColor,
              title: Text(
                'Quit?',
                style: TextStyle(
                  color: kFluggleLetterColor,
                ),
              ),
              content: Text('Are you sure you want to quit?'),
              actions: [
                TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    _confirmQuit(context);
                  },
                ),
                TextButton(
                  child: Text('No'),
                  onPressed: () {
                    _cancelQuit(context);
                  },
                )
              ],
            ),
          );
        });
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Function quitGame) {
    return AppBar(
      backgroundColor: kFlugglePrimaryColor,
      automaticallyImplyLeading: true,
      leading: Center(
        child: EggTimer(
          gameStarted: gameStarted,
          timerEndedCallback: () {
            _timerEnded(context);
          },
        ),
      ),
      leadingWidth: 120,
      title: const Text('Fluggle'),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ButtonTheme(
            child: ElevatedButton(
              style: kElevatedButtonStyle,
              child: Text('Quit'),
              onPressed: () {
                _showQuitGameDialog(context);
                //quitGame();
                //Navigator.of(context).pop(null);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameTopPanel(double topPanelHeight) {
    return Container(
      height: topPanelHeight,
      child: GameTopWidget(
        gameStarted: gameStarted,
        swipedGridItems: swipedGridItems,
        addedWords: _addedWords,
        currentWord: currentWord,
      ),
    );
  }

  Widget _buildGameBoard(double height) {
    return Container(
      //color: Colors.black26,
      /*padding: EdgeInsets.all(GAME_BOARD_PADDING),*/
      height: height,
      child: GameBoardWidget(
          gameStarted: gameStarted,
          letters: letters,
          gridItems: gridItems,
          addSwipedGridItem: _addSwipedGridItem,
          isSwipedGridItem: _isSwipedGridItem,
          getSwipedGridItems: _getSwipedGridItems,
          resetSwipedItems: _resetSwipedItems,
          addWord: _addWord),
    );
  }

  void setupGame() {
    debugPrint('setupGame');
    _setEmptyLetters();
    _updateGridData();
    _resetWords();
  }

  void startGame() async {
    debugPrint('startGame');
    await _animateLetters();
    _shuffleLetters();
    _updateGridData();
    _resetWords();
    setState(() {
      gameStarted = true;
    });
  }

  void quitGame(BuildContext context) {
    setState(() {
      gameStarted = false;
    });
    Navigator.of(context).pop(null);
  }

  void _setEmptyLetters() {
    List<String> emptyLetters = [];
    GAME_LETTERS.forEach((cube) => emptyLetters.add('?'));
    setState(() {
      letters = emptyLetters;
      swipedGridItems = [];
    });
  }

  Future _animateLetters() async {
    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    bool running = true;

    Timer(const Duration(milliseconds: 2500), () {
      running = false;
    });

    while (running) {
      debugPrint('>>> running >>');
      for (int l = 0; l < 16; l++) {
        await Future.delayed(const Duration(microseconds: 1));
        setState(() {
          letters[l] = AZ_LETTERS[rnd.nextInt(AZ_LETTERS.length)];
        });
        _updateGridData();
      }
    }

    debugPrint('<<< finished <<<');
    return;
  }

  void _shuffleLetters() {
    for (var letterCube in GAME_LETTERS) {
      letterCube.shuffle();
    }
    GAME_LETTERS.shuffle();

    List<String> shuffledLetters = [];
    GAME_LETTERS.forEach((cube) => shuffledLetters.add(cube[0]));
    debugPrint('shuffledLetters: ${shuffledLetters}');
    setState(() {
      letters = shuffledLetters;
    });
  }

  void _updateGridData() {
    List<List<GridItem>> localGridItems = [];
    for (int rowCounter = 0; rowCounter < 4; rowCounter++) {
      List<GridItem> gridRow = [];
      for (int colCounter = 0; colCounter < 4; colCounter++) {
        int letterIndex = (rowCounter * 4) + colCounter;
        String letter = letters[letterIndex];
        gridRow.add(GridItem(row: rowCounter, col: colCounter, letter: letter));
      }
      localGridItems.add(gridRow);
    }

    String rows = "";
    for (int rowCounter = 0; rowCounter < 4; rowCounter++) {
      String row = "";
      for (int colCounter = 0; colCounter < 4; colCounter++) {
        row = '${row},${localGridItems[rowCounter][colCounter].letter}';
      }
      rows = '${rows}\n${row}';
    }
    debugPrint('${rows}');

    setState(() {
      gridItems = localGridItems;
    });
  }
}
