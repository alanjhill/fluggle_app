import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:fluggle_app/alert_dialogs/alert_dialogs.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/game/game_state.dart';
import 'package:fluggle_app/models/game/player.dart';
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
import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamePage extends ConsumerStatefulWidget {
  final Game game;
  GamePage({Key? key, required this.game}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final GameService gameService = GameService();
  Dictionary? dictionary;
  List<String>? letters;
  List<List<GridItem>> gridItems = [];
  List<String> shuffledLetters = [];
  List<String> emptyLetters = [];

  @override
  void initState() {
    super.initState();
    letters = _getEmptyLetters();
    _setupGame(widget.game);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
    gameStateNotifier.reset();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final PreferredSizeWidget appBar = _buildAppBar(context, ref, _quitGame);

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

  void _resetWords(GameState gameState) {
    setState(() {
      gameState.addedWords.clear();
    });
  }

  Future<void> _timerEnded(BuildContext context, WidgetRef ref) async {
    debugPrint('timerEnded');
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;

    final gameState = ref.read(gameStateProvider);

    // If practice mode, we don't save anything, just redirect to the scores page, passing the game object
    if (widget.game.practice == true) {
      // Set the words for this player
      Player player = widget.game.players[0];
      player.words = gameState.addedWords;
      widget.game.playerUids[player.playerId] = PlayerStatus.finished;

      Navigator.of(context).pop(null);
      Navigator.of(context).pushNamed(ScoresPage.routeName, arguments: widget.game);
    } else {
      // Real game, go to the scores page, passing the game object
      final database = ref.read(databaseProvider);

      // Get Player
      Player player = await database.getGamePlayer(gameId: widget.game.gameId!, playerUid: user!.uid);

      // Set the words for this player
      player.words = gameState.addedWords;

      // Set the status of this player to finished
      widget.game.playerUids[user.uid] = PlayerStatus.finished;

      // Save the game status of this player
      await gameService.saveGameAndPlayer(ref, game: widget.game, player: player);

      // Go to scoreboard
      Navigator.of(context).pop(null);
      Navigator.of(context).pushNamed(ScoresPage.routeName, arguments: widget.game);
    }
  }

  void _confirmQuit(BuildContext context, WidgetRef ref) {
    _quitGame(context, ref);
  }

  void _showQuitGameDialog(BuildContext context, WidgetRef ref) async {
    final bool didConfirmQuit = await showAlertDialog(
          context: context,
          title: Strings.quit,
          content: Strings.quitAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.ok,
        ) ??
        false;
    if (didConfirmQuit == true) {
      _confirmQuit(context, ref);
    }
  }

  String _getTitleText() {
    if (widget.game.practice == true) {
      return Strings.practice;
    } else {
      return Strings.playing;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, Function quitGame) {
    final gameState = ref.read(gameStateProvider);
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (gameState.gameStarted) {
            _showQuitGameDialog(context, ref);
          } else {
            Navigator.of(context).pushNamed(AppRoutes.playGamePage);
          }
        },
      ),
      titleText: _getTitleText(),
      actions: <Widget>[
        Center(
          child: CountdownTimer(
            gameStarted: gameState.gameStarted,
            gamePaused: gameState.gamePaused,
            gameTime: widget.game.gameTime,
            timerEndedCallback: () async {
              await _timerEnded(context, ref);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameTopPanel(double topPanelHeight) {
    return Container(
      height: topPanelHeight,
      child: GameTopPanel(),
    );
  }

  Widget _buildGameBoard(double height) {
    return Container(
        height: height,
        child: GameBoard(
          dictionary: dictionary,
          letters: letters!,
          gridItems: gridItems,
        ));
  }

  Widget _buildGameBottomPanel(double bottomPanelHeight) {
    return GameBottomPanel(
      startButtonPressed: _startGame,
      pauseButtonPressed: _pauseGame,
      height: bottomPanelHeight,
    );
  }

  void _setupGame(Game game) {
    debugPrint('setupGame');
    shuffledLetters = widget.game.letters;

    /// Load the words for the specified language
    Language.forLanguageCode('en-GB').then((language) {
      dictionary = language.dictionary;
    });

    _updateGridData();
  }

  void _startGame(BuildContext context, WidgetRef ref) async {
    final gameState = ref.read(gameStateProvider);
    debugPrint('startGame');
    await _animateLetters(gameState);
    _updateGridData();
    _resetWords(gameState);
    setState(() {
      gameState.gameStarted = true;
    });
  }

  void _pauseGame(BuildContext context, WidgetRef ref) {
    //final gameStateNotifier = context.read(gameStateProvider.notifier);
    final gameState = ref.read(gameStateProvider);
    debugPrint('pauseGame');
    //gameStateNotifier.toggleGamePaused();
    setState(() {
      gameState.gamePaused = !gameState.gamePaused;
    });
    _displayPopup(context, ref);
  }

  void _displayPopup(BuildContext context, WidgetRef ref) {
    final gameStateNotifier = ref.read(gameStateProvider.notifier);
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
                      gameStateNotifier.toggleGamePaused();
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

  void _quitGame(BuildContext context, WidgetRef ref) async {
    final gameState = ref.read(gameStateProvider);
    setState(() {
      gameState.gameStarted = false;
    });
    // Update the PlayerStatus for this player
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;

    // Save the game
    await gameService.saveGame(ref, game: widget.game, playerStatus: PlayerStatus.resigned, uid: user!.uid);

    // Navigate to the Play Game Page
    Navigator.of(context).pushReplacementNamed(AppRoutes.playGamePage);
  }

  List<String> _getEmptyLetters() {
    List<String> emptyLetters = [];
    for (int i = 0; i < 16; i++) {
      emptyLetters.add('?');
    }
    return emptyLetters;
  }

  Future _animateLetters(GameState gameState) async {
    Random rnd = Random(DateTime.now().millisecondsSinceEpoch);
    bool running = true;

    Timer(const Duration(milliseconds: 500), () {
      running = false;
    });

    while (running) {
      for (int l = 0; l < 16; l++) {
        await Future.delayed(const Duration(microseconds: 1));
        setState(() {
          letters![l] = kAZLetters[rnd.nextInt(kAZLetters.length)];
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
        String letter = letters![letterIndex];
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
