import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
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
  final vm = UserViewModel(database: firestoreDatabase);
  return vm.findUserByUid(uid: uid);
});

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final firebaseAuth = context.read(firebaseAuthProvider);
    final user = firebaseAuth.currentUser;
    final bool isSignedIn = user != null;
    AppUser appUser = watch(userStreamProvider(user!.uid)).data?.value as AppUser;

    return Scaffold(
      appBar: customAppBar(
        title: Strings.appName,
        centerTitle: true,
        backButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 8.0),
                CustomRaisedButton(
                  child: Text('Play'),
                  onPressed: isSignedIn ? () => playGame(context) : null,
                ),
                SizedBox(height: 8.0),
                CustomRaisedButton(
                  child: Text('Friends'),
                  onPressed: isSignedIn ? () => friendsList(context) : null,
                ),
                SizedBox(height: 8.0),
                CustomRaisedButton(
                  child: Text('Previous Games'),
                  onPressed: isSignedIn ? () => previousGames(context) : null,
                ),
                SizedBox(height: 8.0),
                !isSignedIn
                    ? CustomRaisedButton(
                        child: Text('Sign In'),
                        onPressed: () => signIn(context),
                      )
                    : CustomRaisedButton(
                        child: Text('Your Account'),
                        onPressed: () => accountPage(context),
                      ),
                SizedBox(height: 8.0),
                appUser.admin == true
                    ? CustomRaisedButton(
                        child: Text('Onboarding Incomplete'),
                        onPressed: () async {
                          await onboardingIncomplete(context);
                        },
                      )
                    : Container(),
              ],
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

  Future<void> onboardingIncomplete(BuildContext context) async {
    final OnboardingViewModel onboardingViewModel = context.read(onboardingViewModelProvider.notifier);
    await onboardingViewModel.setCompleteOnboardingFalse();
  }
}
