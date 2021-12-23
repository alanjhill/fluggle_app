import 'package:fluggle_app/pages/account/account_page.dart';
import 'package:fluggle_app/pages/friends/friends_page.dart';
import 'package:fluggle_app/pages/help_page/help_page.dart';
import 'package:fluggle_app/pages/play_game/play_game_page.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_page.dart';
import 'package:fluggle_app/widgets/word_cubes.dart';
import 'package:fluggle_app/constants/constants.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/user_view_model.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_view_model.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userStreamProvider = StreamProvider.autoDispose.family<AppUser, String>((ref, String uid) {
  final firestoreDatabase = ref.watch(databaseProvider);
  final vm = UserViewModel(database: firestoreDatabase!);
  return vm.findUserByUid(uid: uid);
});

class HomePage extends ConsumerStatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController bottomSheetAnimationController;
  final _pages = [
    const PlayGamePage(),
    const FriendsPage(),
    const PreviousGamesPage(),
    const AccountPage(),
    const HelpPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    bottomSheetAnimationController = BottomSheet.createAnimationController(this);
    bottomSheetAnimationController.duration = const Duration(milliseconds: 500);
    bottomSheetAnimationController.reverseDuration = const Duration(milliseconds: 250);
  }

  @override
  void dispose() {
    super.dispose();
    bottomSheetAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, __) {
      //final appState = ref.watch(appStateProvider);
      return Scaffold(
        body: SafeArea(
          //bottom: false,
          child: IndexedStack(index: _selectedTab, children: _pages),
        ),
        bottomNavigationBar: BottomAppBar(
          notchMargin: 0,
          shape: AutomaticNotchedShape(
            const RoundedRectangleBorder(),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(width: 1.0, style: BorderStyle.solid),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
                //splashColor: Colors.transparent,
                //highlightColor: Colors.transparent,
                ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: 'PLAY',
                  icon: Icon(Icons.play_arrow),
                ),
                BottomNavigationBarItem(
                  label: 'FRIENDS',
                  icon: Icon(
                    Icons.people,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'Games',
                  icon: Icon(
                    Icons.history,
                  ),
                ),
                BottomNavigationBarItem(
                  label: 'ACCOUNT',
                  icon: Icon(Icons.manage_accounts),
                ),
                BottomNavigationBarItem(
                  label: 'HELP',
                  icon: Icon(
                    Icons.help_outline,
                  ),
                ),
              ],
              currentIndex: _selectedTab,
              onTap: _onTap,
            ),
          ),
        ),
      );
    });
  }

  void _onTap(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void accountPage(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.accountPage);
  }

  void playGame(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.playGamePage);
  }

  void friendsList(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.friendsPage);
  }

  void previousGames(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.previousGamesPage);
  }

  void signIn(BuildContext ctx) {
    //Navigator.of(ctx).pushNamed(AppRoutes.emailPasswordSignInPage);
    Navigator.of(ctx).pushNamed(AppRoutes.signInPage);
  }

  void help(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(AppRoutes.helpPage);
  }

  Future<void> onboardingIncomplete(BuildContext context, WidgetRef ref) async {
    final OnboardingViewModel onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);
    await onboardingViewModel.setCompleteOnboardingFalse();
  }
}
