import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/auth/application_state.dart';
import 'package:fluggle_app/auth/authentication.dart';
import 'package:fluggle_app/auth/widgets.dart';
import 'package:fluggle_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = 'login';

  @override
  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kFlugglePrimaryColor,
        title: const Text('Login'),
      ),
      body: ListView(
        children: <Widget>[
          // Add from here
          Consumer<ApplicationState>(
            builder: (context, appState, _) => Authentication(
              email: appState.email,
              loginState: appState.loginState,
              startLoginFlow: appState.startLoginFlow,
              verifyEmail: appState.verifyEmail,
              signInWithEmailAndPassword: appState.signInWithEmailAndPassword,
              cancelRegistration: appState.cancelRegistration,
              registerAccount: appState.registerAccount,
              signOut: appState.signOut,
            ),
          ),
        ],
      ),
    );
  }
}
