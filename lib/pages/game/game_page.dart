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
  final GameArguments gameArguments;
  const GamePage({Key? key, required this.gameArguments}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  Dictionary? dictionary;
  List<String>? letters;
  List<List<GridItem>> gridItems = [];
  List<String> shuffledLetters = [];
  List<String> emptyLetters = [];

  late final Game game;
  late final List<Player> players;

  @override
  void initState() {
    super.initState();
    game = widget.gameArguments.game;
    players = widget.gameArguments.players;

    // 'Fix' to prevent exception
    Future.delayed(Duration.zero, () {
      final gameStateNotifier = ref.read(gameStateProvider.notifier);
      gameStateNotifier.reset();
    });

    letters = _getEmptyLetters();
    _setupGame(game);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  Future<void> _timerEnded(BuildContext context, WidgetRef ref) async {
    debugPrint('>>> _timerEnded');
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final gameService = ref.read(gameServiceProvider);

    // Get this player
    Player player = players.firstWhere((p) => p.playerId == user!.uid);

    // This player has finished, save their data and update other finished players
    await gameService.playerFinished(ref, game: game, player: player, uid: user!.uid);

    // Pop this page off the stack
    Navigator.of(context).pop(null);

    // Create the game arguments for passing to the Scores Page
    GameArguments gameArgs = GameArguments(game: game, players: players);

    // Go to the scores page
    Navigator.of(context).pushNamed(ScoresPage.routeName, arguments: gameArgs);
    debugPrint('<<< _timerEnded');
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
    if (game.practice == true) {
      return Strings.practice;
    } else {
      return Strings.playing;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, Function quitGame) {
    final gameState = ref.watch(gameStateProvider);
    return CustomAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
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
            duration: game.gameTime,
            timerStarted: gameState.gameStarted,
            timerPaused: gameState.gamePaused,
            timerEndedCallback: () async {
              await _timerEnded(context, ref);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameTopPanel(double topPanelHeight) {
    return SizedBox(
      height: topPanelHeight,
      child: const GameTopPanel(),
    );
  }

  Widget _buildGameBoard(double height) {
    return SizedBox(
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
    shuffledLetters = game.letters;

    /// Load the words for the specified language
    Language.forLanguageCode('en-GB').then((language) {
      dictionary = language.dictionary;
    });

    _updateGridData();
  }

  void _startGame(BuildContext context, WidgetRef ref) async {
    final gameState = ref.read(gameStateProvider.notifier);
    debugPrint('startGame');
    await _animateLetters();
    setState(() {
      letters = shuffledLetters;
    });
    _updateGridData();
    gameState.resetWords();
    gameState.startGame();
  }

  void _pauseGame(BuildContext context, WidgetRef ref) {
    final gameStateNotifier = ref.watch(gameStateProvider.notifier);
    gameStateNotifier.toggleGamePaused();
    _displayPopup(context, ref);
  }

  void _displayPopup(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      barrierDismissible: false,
      barrierLabel: 'x',
      context: context,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: CustomRaisedButton(
              child: const Text('Resume'),
              onPressed: () {
                final gameStateNotifier = ref.watch(gameStateProvider.notifier);
                gameStateNotifier.toggleGamePaused();
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      transitionBuilder: _buildSlideTransition,
    );
  }

  Widget _buildSlideTransition(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
      child: child,
    );
  }

  void _quitGame(BuildContext context, WidgetRef ref) async {
    final gameService = ref.read(gameServiceProvider);
    final gameState = ref.read(gameStateProvider.notifier);

    // Update the PlayerStatus for this player
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;

    // Quit and save the gate
    gameState.quitGame();
    await gameService.saveGame(ref, game: game, playerStatus: PlayerStatus.resigned, uid: user!.uid);

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

class GameArguments {
  final Game game;
  final List<Player> players;
  GameArguments({required this.game, required this.players});
}
