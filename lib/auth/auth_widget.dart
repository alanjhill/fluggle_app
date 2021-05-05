import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/screens/home/home_screen.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:fluggle_app/screens/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';

/// Builds the signed-in or non signed-in UI, depending on the user snapshot.
/// This widget should be below the [MaterialApp].
/// An [AuthWidgetBuilder] ancestor is required for this widget to work.
/// Note: this class used to be called [LandingPage].
class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key, required this.userSnapshot}) : super(key: key);
  final AsyncSnapshot<FluggleUser?> userSnapshot;

  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active) {
      //if (userSnapshot.hasData) {
      debugPrint('>>> HomeScreen >>>');
      return HomeScreenBuilder();
      //} else {
      //debugPrint('>>> SignInPageBuilder >>>');
      //return SignInPageBuilder();
      //}
    }
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
