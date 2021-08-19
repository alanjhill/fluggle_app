import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/pages/account/account_page.dart';
import 'package:fluggle_app/pages/friends/friends_page.dart';
import 'package:fluggle_app/pages/friends_search/friends_search_page.dart';
import 'package:fluggle_app/pages/game/game_page.dart';
import 'package:fluggle_app/pages/help_page/help_page.dart';
import 'package:fluggle_app/pages/home/home_page.dart';
import 'package:fluggle_app/pages/play_game/play_game_page.dart';
import 'package:fluggle_app/pages/previous_games/previous_games_page.dart';
import 'package:fluggle_app/pages/scores/scores_page.dart';
import 'package:fluggle_app/pages/sign_in/email_password/email_password_sign_in_ui.dart';
import 'package:fluggle_app/pages/sign_in/sign_in_page.dart';
import 'package:fluggle_app/pages/start_game/start_game_page.dart';
import 'package:fluggle_app/widgets/page_transition.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const accountPage = '/account';
  static const friendsPage = '/friends';
  static const friendsSearchPage = '/friends/search';
  static const gamePage = '/game';
  static const homePage = '/home';
  static const emailPasswordSignInPage = '/email-password-sign-in';
  static const updateUserPage = "/update-user";
  static const playGamePage = '/play-game';
  static const previousGamesPage = '/previous-games';
  static const scoresPage = '/scores';
  static const signInPage = '/sign-in';
  static const startGamePage = '/start-game';
  static const helpPage = '/help-page';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(BuildContext context, RouteSettings settings, FirebaseAuth auth) {
    final args = settings.arguments;
    debugPrint('args: $args');
    switch (settings.name) {
      case AppRoutes.emailPasswordSignInPage:
        return pageTransition(
          context,
          page: EmailPasswordSignInPage.withFirebaseAuth(
            auth,
            onSignedIn: args as void Function(),
          ),
        );
      case AppRoutes.updateUserPage:
        return pageTransition(
          context,
          page: EmailPasswordSignInPage.updateUser(
            auth,
          ),
        );
      case AppRoutes.signInPage:
        return pageTransition(
          context,
          page: SignInPage(),
        );
      case AppRoutes.homePage:
        return pageTransition(
          context,
          page: HomePage(),
        );
      case AppRoutes.gamePage:
        return pageTransition(
          context,
          page: GamePage(game: args as Game),
        );
      case AppRoutes.friendsPage:
        return pageTransition(
          context,
          page: FriendsPage(),
        );
      case AppRoutes.friendsSearchPage:
        return pageTransition(
          context,
          page: FriendsSearchPage(),
        );
      case AppRoutes.playGamePage:
        return pageTransition(
          context,
          page: PlayGamePage(),
        );
      case AppRoutes.startGamePage:
        return pageTransition(
          context,
          page: StartGamePage(startGameArguments: args as StartGameArguments),
        );
      case AppRoutes.scoresPage:
        return pageTransition(
          context,
          page: ScoresPage(game: args as Game),
        );
      case AppRoutes.previousGamesPage:
        return pageTransition(
          context,
          page: PreviousGamesPage(),
        );
      case AppRoutes.accountPage:
        return pageTransition(
          context,
          page: AccountPage(),
        );
      case AppRoutes.helpPage:
        return pageTransition(
          context,
          page: HelpPage(),
        );
    }
  }
}
