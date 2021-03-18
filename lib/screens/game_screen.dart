import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game_letters.dart';
import 'package:fluggle_app/models/grid_item.dart';
import 'package:fluggle_app/widgets/egg_timer.dart';
import 'package:fluggle_app/widgets/game_board.dart';
import 'package:fluggle_app/widgets/game_board_bottom_bar.dart';
import 'package:fluggle_app/widgets/game_top_panel.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  static const String routeName = "game";

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> letters = [];
  List<List<GridItem>> gridItems;
  List<GridItem> swipedGridItems = [];
  List<String> addedWords = [];
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
    final PreferredSizeWidget appBar = _buildAppBar(quitGame);
    final availableHeight = (screenHeight - appBar.preferredSize.height - screenWidth - mediaQuery.padding.top - kSTATUS_BAR_HEIGHT);

    // Top Panel for entered words, number of words, timer etc
    final gameTopPanel = Container(
      color: Colors.white,
      height: availableHeight,
      child: GameTopPanel(gameStarted: gameStarted, swipedGridItems: swipedGridItems, addedWords: _addedWords),
    );

    // Game Board for the grid and letters
    final gameBoard = Container(
      /*padding: EdgeInsets.all(GAME_BOARD_PADDING),*/
      height: screenWidth,
      child: GameBoard(
          gameStarted: gameStarted,
          letters: letters,
          gridItems: gridItems,
          addSwipedGridItem: _addSwipedGridItem,
          isSwipedGridItem: _isSwipedGridItem,
          getSwipedGridItems: _getSwipedGridItems,
          resetSwipedItems: _resetSwipedItems,
          addWord: _addWord),
    );

    // Status Bar (which we might not need)
    final gameBoardBottomBar = GameBoardBottomBar(
      gameStarted: gameStarted,
      startButtonPressed: startGame,
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
      if (!swipedGridItems.contains(gridItem) && (_isAdjacent(gridItem) || _isFirstItem())) {
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

  bool _isAdjacent(GridItem gridItem) {
    GridItem lastAddedItem = swipedGridItems.isNotEmpty ? swipedGridItems.last : null;

    bool adjacent = false;
    if (lastAddedItem != null) {
      int diffX = (lastAddedItem.col - gridItem.col).abs();
      int diffY = (lastAddedItem.row - gridItem.row).abs();
      adjacent = ([0, 1].contains(diffX) && [0, 1].contains(diffY));
    }

    debugPrint('_isAdjacent: ${adjacent}');
    return adjacent;
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
        debugPrint('words: ${addedWords}');
      });
    }

    // Reset the swiped items
    _resetGridItems();
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

  void timerEnded() {
    debugPrint('timerEnded');
  }

  Widget _buildAppBar(Function quitGame) {
    return AppBar(
        automaticallyImplyLeading: true,
        leading: Center(child: EggTimer(gameStarted: gameStarted, timerEndedCallback: timerEnded)),
        leadingWidth: 12git`0,
        title: const Text('Fluggle'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ButtonTheme(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: KFlugglePrimaryColor,
                  padding: EdgeInsets.all(0.0),
                ),
                child: Text('Quit'),
                onPressed: () {
                  quitGame();
                  Navigator.of(context).pop(null);
                },
              ),
            ),
          ),
        ]);
  }

  void setupGame() {
    debugPrint('Start Game');
    _shuffleGameLetters();
    _updateGridData();
    _resetWords();
  }

  void startGame() {
    debugPrint('Start Game');
    setState(() {
      gameStarted = true;
    });
  }

  void quitGame() {
    setState(() {
      gameStarted = false;
    });
  }

  void _shuffleGameLetters() {
    for (var letterCube in GAME_LETTERS) {
      letterCube.shuffle();
    }
    GAME_LETTERS.shuffle();

    List<String> shuffledLetters = [];
    GAME_LETTERS.forEach((cube) => shuffledLetters.add(cube[0]));
    debugPrint('shuffledLetters: ${shuffledLetters}');
    setState(() {
      letters = shuffledLetters;
      swipedGridItems = [];
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
