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

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    debugPrint('user.displayName: ${user?.displayName}');
    bool isSignedIn = user != null;
    bool isAnonymous = true;
    if (user != null) {
      isAnonymous = user.isAnonymous;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(kPagePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: WordCubes(word: 'FLUGGLE', width: MediaQuery.of(context).size.width - 32, spacing: 1.0),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'A BOGGLE like word game\nwritten using Flutter',
                    style: TextStyle(),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  CustomRaisedButton(
                    child: Text('Play'),
                    onPressed: isSignedIn ? () => playGame(context) : null,
                  ),
                  SizedBox(height: 8.0),
                  CustomRaisedButton(
                    child: Text('Friends'),
                    onPressed: isSignedIn && !isAnonymous ? () => friendsList(context) : null,
                  ),
                  SizedBox(height: 8.0),
                  CustomRaisedButton(
                    child: Text('Previous Games'),
                    onPressed: isSignedIn && !isAnonymous ? () => previousGames(context) : null,
                  ),
                  SizedBox(height: 8.0),
                  !isSignedIn
                      ? CustomRaisedButton(
                          child: Text('Sign In'),
                          onPressed: () => signIn(context),
                        )
                      : CustomRaisedButton(
                          child: Text(Strings.accountPage),
                          onPressed: () => accountPage(context),
                        ),
                  SizedBox(height: 8.0),
                  CustomRaisedButton(
                    child: Text('Help'),
                    onPressed: () => help(context),
                  ),
/*                SizedBox(height: 8.0),
                  appUser?.admin == true
                      ? CustomRaisedButton(
                          child: Text('Onboarding Incomplete'),
                          onPressed: () async {
                            await onboardingIncomplete(context);
                          },
                        )
                      : Container(),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
