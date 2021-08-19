import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_word.dart';
import 'package:fluggle_app/models/game/player.dart';
import 'package:fluggle_app/models/game/player_word.dart';
import 'package:fluggle_app/models/game_board/game_letters.dart';
import 'package:fluggle_app/models/game_board/grid_item.dart';
import 'package:fluggle_app/pages/game/game_board.dart';
import 'package:fluggle_app/pages/game/game_bottom_panel.dart';
import 'package:fluggle_app/pages/game/game_top_panel.dart';
import 'package:fluggle_app/pages/scores/scores_page.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:fluggle_app/utils/dictionary.dart';
import 'package:fluggle_app/utils/language.dart';
import 'package:fluggle_app/widgets/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WordStatus { empty, valid, invalid, duplicate }

class GamePage extends StatelessWidget {
  final Game game;
  GamePage({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GamePageWidget(game: game);
  }
}

class GamePageWidget extends StatefulWidget {
  GamePageWidget({required this.game});
  final Game game;

  @override
  _GamePageWidgetState createState() => _GamePageWidgetState();
}

class _GamePageWidgetState extends State<GamePageWidget> {
  final GameService gameService = GameService();
  List<String> letters = [];
  List<String> shuffledLetters = [];
  List<String> emptyLetters = [];
  List<List<GridItem>> gridItems = [];
  List<GridItem> swipedGridItems = [];
  LinkedHashMap<String, PlayerWord> addedWords = LinkedHashMap<String, PlayerWord>();
  String currentWord = "";
  WordStatus currentWordStatus = WordStatus.empty;
  Dictionary? dictionary;
  bool gameStarted = false;
  bool gamePaused = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final PreferredSizeWidget appBar = _buildAppBar(context, _quitGame, gameStarted);

    final appBarHeight = appBar.preferredSize.height;
    final gameBoardHeight = screenWidth - kGameBoardPadding;
    final remainingHeight = screenHeight - appBarHeight - gameBoardHeight - mediaQuery.padding.top;
    final topPanelHeight = remainingHeight / 3 * 2;

    // Top Panel for entered words, number of words, timer etc
    final gameTopPanel = _buildGameTopPanel(topPanelHeight);

    // Game Board for the grid and letters
    final gameBoard = _buildGameBoard(screenWidth - kGameBoardPadding);

    // Bottom panel / button bar
    final gameBottomPanel = _buildGameBottomPanel(kBottomBarHeight);

    // Bottom Bar

    return Scaffold(
      appBar: appBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          gameTopPanel,
          gameBoard,
          gameBottomPanel,
        ],
      ),
    );
  }

  LinkedHashMap<String, PlayerWord> get _addedWords {
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
      currentWordStatus = WordStatus.empty;
      GridItem? lastAddedGridItem = swipedGridItems.isNotEmpty ? swipedGridItems.last : null;
      if (!swipedGridItems.contains(gridItem) && (gridItem.isAdjacent(lastAddedGridItem) || _isFirstItem())) {
        swipedGridItems.add(gridItem);
        added = true;
      }
    });
    debugPrint('_addSwipedGridItem, added; $added');
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

    setState(() {
      // Set the current word
      currentWord = word;

      // Add the word to the list of words if it does not exist
      if (word.length >= 3) {
        // Check if word exists in dictionary
        if (dictionary!.exists(currentWord)) {
          if (!addedWords.containsKey(word)) {
            addedWords[word] = PlayerWord(gameWord: GameWord(word: word), gridItems: swipedGridItems);
            currentWordStatus = WordStatus.valid;
          } else {
            currentWordStatus = WordStatus.duplicate;
          }
        } else {
          // Doesn't exist in dictionary, invalid
          currentWordStatus = WordStatus.invalid;
        }
      } else {
        // Word is too short
        currentWordStatus = WordStatus.invalid;
      }
    });

    // Reset the swiped items
    _resetGridItems();
  }

  void _updateCurrentWord() {
    for (GridItem gridItem in swipedGridItems) {
      setState(() {
        currentWord += gridItem.letter;
        debugPrint('currentWord: $currentWord');
      });
    }
  }

  void _resetGridItems() {
    for (var gridItem in swipedGridItems) {
      setState(() {
        gridItem.swiped = false;
      });
    }
  }

  void _resetSwipedItems() {
    setState(() {
      swipedGridItems = [];
    });
  }

  Future<void> _timerEnded(BuildContext context) async {
    debugPrint('timerEnded');
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;

    // If practice mode, we don't save anything, just redirect to the scores page, passing the game object
    if (widget.game.practice == true) {
      // Set the words for this player
      Player player = widget.game.players[0];
      player.words = addedWords;
      widget.game.playerUids[player.playerId] = PlayerStatus.finished;

      Navigator.of(context).pop(null);
      Navigator.of(context).pushNamed(ScoresPage.routeName, arguments: widget.game);
    } else {
      // Real game, go to the scores page, passing the game object
      final database = context.read(databaseProvider);

      // Get Player
      Player player = await database.getGamePlayer(gameId: widget.game.gameId!, playerUid: user!.uid);

      // Set the words for this player
      player.words = addedWords;

      // Set the status of this player to finished
      widget.game.playerUids[user.uid] = PlayerStatus.finished;

      // Save the game status of this player
      await gameService.saveGameAndPlayer(context, game: widget.game, player: player);

      // Go to scoreboard
      Navigator.of(context).pop(null);
      Navigator.of(context).pushNamed(ScoresPage.routeName, arguments: widget.game);
    }
  }

  void _confirmQuit(BuildContext context) {
    debugPrint('confirmQuit');
    Navigator.pop(context);
    _quitGame(context);
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
              backgroundColor: kFluggleLightColor,
              title: Text(
                'Quit?',
                style: TextStyle(
                    //color: kFluggleLetterColor,
                    ),
              ),
              content: Text('Are you sure you want to quit?'),
              actions: [
                ButtonTheme(
                  child: CustomRaisedButton(
                    child: Text('Yes'),
                    onPressed: () {
                      _confirmQuit(context);
                    },
                  ),
                ),
                ButtonTheme(
                  child: CustomRaisedButton(
                    child: Text('No'),
                    onPressed: () {
                      _cancelQuit(context);
                    },
                  ),
                )
              ],
            ),
          );
        });
  }

  String _getTitleText() {
    if (widget.game.practice == true) {
      return Strings.practice;
    } else {
      return Strings.playing;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Function quitGame, bool gameStarted) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (gameStarted) {
            _showQuitGameDialog(context);
          } else {
            //Navigator.of(context).pop();
            Navigator.of(context).pushNamed(AppRoutes.playGamePage);
          }
        },
      ),
      titleText: _getTitleText(),
      actions: <Widget>[
        Center(
          child: CountdownTimer(
            gameStarted: gameStarted,
            gamePaused: gamePaused,
            gameTime: widget.game.gameTime,
            timerEndedCallback: () async {
              await _timerEnded(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameTopPanel(double topPanelHeight) {
    return Container(
      height: topPanelHeight,
      child: GameTopPanel(
        gameStarted: gameStarted,
        swipedGridItems: swipedGridItems,
        addedWords: _addedWords,
        currentWord: currentWord,
        currentWordStatus: currentWordStatus,
      ),
    );
  }

  Widget _buildGameBoard(double height) {
    return Container(
        //color: Colors.black26,
        /*padding: EdgeInsets.all(GAME_BOARD_PADDING),*/
        height: height,
        child: GameBoard(
          gameStarted: gameStarted,
          letters: letters,
          gridItems: gridItems,
          addSwipedGridItem: _addSwipedGridItem,
          isSwipedGridItem: _isSwipedGridItem,
          getSwipedGridItems: _getSwipedGridItems,
          resetSwipedItems: _resetSwipedItems,
          addWord: _addWord,
          updateCurrentWord: _updateCurrentWord,
        ));
  }

  Widget _buildGameBottomPanel(double bottomPanelHeight) {
    return GameBottomPanel(
      gameStarted: gameStarted,
      gamePaused: gamePaused,
      startButtonPressed: _startGame,
      pauseButtonPressed: _pauseGame,
      height: bottomPanelHeight,
    );
  }

  void _setupGame() {
    debugPrint('setupGame');
    shuffledLetters = widget.game.letters;

    /// Load the words for the specified language
    Language.forLanguageCode('en-GB').then((language) {
      //debugPrint('language: ${language} loaded');
      dictionary = language.dictionary;
    });

    _setEmptyLetters();
    _updateGridData();
    _resetWords();
  }

  void _startGame() async {
    debugPrint('startGame');
    await _animateLetters();
    letters = shuffledLetters;
    _updateGridData();
    _resetWords();
    setState(() {
      gameStarted = true;
    });
  }

  void _pauseGame(BuildContext context) {
    debugPrint('pauseGame');
    setState(() {
      gamePaused = !gamePaused;
      _displayPopup(context);
    });
  }

  void _displayPopup(BuildContext context) {
    showGeneralDialog(
      barrierLabel: 'x',
      context: context,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Container(
          child: Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: CustomRaisedButton(
                child: Text('Resume'),
                onPressed: () {
                  setState(
                    () {
                      gamePaused = !gamePaused;
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: _buildSlideTransition,
    );
  }

  Widget _buildSlideTransition(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(animation),
      child: child,
    );
  }

  void _quitGame(BuildContext context) async {
    setState(() {
      gameStarted = false;
    });
    // Update the PlayerStatus for this player
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;

    // Save the game
    await gameService.saveGame(context, game: widget.game, playerStatus: PlayerStatus.resigned, uid: user!.uid);

    // Navigate to the Play Game Page
    Navigator.of(context).pushNamed(AppRoutes.playGamePage);
  }

  void _setEmptyLetters() {
    List<String> emptyLetters = [];
    for (var _ in shuffledLetters) {
      emptyLetters.add('?');
    }
    setState(() {
      letters = emptyLetters;
      swipedGridItems = [];
    });
  }

  Future _animateLetters() async {
    Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
    bool running = true;

    Timer(const Duration(milliseconds: 500), () {
      running = false;
    });

    while (running) {
      for (int l = 0; l < 16; l++) {
        await Future.delayed(const Duration(microseconds: 1));
        setState(() {
          letters[l] = kAZLetters[rnd.nextInt(kAZLetters.length)];
        });
        _updateGridData();
      }
    }

    debugPrint('<<< finished <<<');
    return;
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
        row = '$row,${localGridItems[rowCounter][colCounter].letter}';
      }
      rows = '$rows\n$row';
    }
    debugPrint(rows);

    setState(() {
      gridItems = localGridItems;
    });
  }
}
