import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/alert_dialogs/alert_dialogs.dart';
import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedantic/pedantic.dart';

final appUserProvider = StreamProvider.autoDispose.family<AppUser, String>((ref, uid) {
  final database = ref.watch(databaseProvider);
  return database!.appUserStream(uid: uid);
});

class AccountPage extends ConsumerWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.watch(firebaseAuthProvider);
    final User? user = firebaseAuth.currentUser;
    if (user != null) {
      user.reload();
    }

    if (user != null) {
      final appUserAsyncValue = ref.watch(appUserProvider(user.uid));
      return Scaffold(
        appBar: CustomAppBar(
          titleText: Strings.accountPage,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 48.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 8.0),
                  user.isAnonymous ? _buildAnonymousUserInfo() : _buildUserInfo(user, appUserAsyncValue),
                  !user.isAnonymous
                      ? CustomRaisedButton(
                          child: const Text(Strings.update),
                          onPressed: () => _updateUser(context, firebaseAuth),
                        )
                      : Container(),
                  !user.isAnonymous ? const SizedBox(height: 8.0) : Container(),
                  CustomRaisedButton(
                    child: const Text(Strings.logout),
                    onPressed: () => _confirmSignOut(context, firebaseAuth),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> _updateUser(BuildContext context, FirebaseAuth firebaseAuth) async {
    Navigator.of(context).pushNamed(AppRoutes.updateUserPage);
  }

  Future<void> _signOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    try {
      await firebaseAuth.signOut();
      Navigator.of(context).pushNamed(AppRoutes.homePage);
    } catch (e) {
      unawaited(showExceptionAlertDialog(
        context: context,
        title: Strings.logoutFailed,
        exception: e,
      ));
    }
  }

  Future<void> _confirmSignOut(BuildContext context, FirebaseAuth firebaseAuth) async {
    final bool didRequestSignOut = await showAlertDialog(
          context: context,
          title: Strings.logout,
          content: Strings.logoutAreYouSure,
          cancelActionText: Strings.cancel,
          defaultActionText: Strings.logout,
        ) ??
        false;
    if (didRequestSignOut == true) {
      await _signOut(context, firebaseAuth);
    }
  }

  Widget _buildAnonymousUserInfo() {
    return _userWidget(displayName: 'Guest');
  }

  Widget _buildUserInfo(user, appUserAsyncValue) {
    return appUserAsyncValue.when(
      data: (appUser) => _userWidget(displayName: user.displayName),
      loading: () => Container(),
      error: (_, __) => Container(),
    );
  }

  Widget _userWidget({required String displayName}) {
    return Column(
      children: <Widget>[
        const Text('Logged in as'),
        const SizedBox(height: 8.0),
        Text(
          displayName,
          style: const TextStyle(fontSize: 24.0),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
