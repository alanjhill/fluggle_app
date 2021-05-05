import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/screens/home/home_screen.dart';
import 'package:fluggle_app/screens/sign_in/email_password/email_password_sign_in_page.dart';
import 'package:fluggle_app/screens/sign_in/sign_in_manager.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPageBuilder extends StatelessWidget {
  static const String routeName = 'sign-in';

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService auth = Provider.of<FirebaseAuthService>(context, listen: false);
    return ChangeNotifierProvider<ValueNotifier<bool>>(
      create: (_) => ValueNotifier<bool>(false),
      child: Consumer<ValueNotifier<bool>>(
        builder: (_, ValueNotifier<bool> isLoading, __) => Provider<SignInManager>(
          create: (_) => SignInManager(auth: auth, isLoading: isLoading),
          child: Consumer<SignInManager>(
            builder: (_, SignInManager manager, __) => SignInPage._(
              isLoading: isLoading.value,
              manager: manager,
              title: Strings.appName,
            ),
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatelessWidget {
  const SignInPage._({
    Key? key,
    required this.isLoading,
    required this.manager,
    required this.title,
  }) : super(key: key);

  final SignInManager manager;
  final String title;
  final bool isLoading;

  static const Key emailPasswordButtonKey = Key('email-password');
  static const Key emailLinkButtonKey = Key('email-link');
  static const Key signOutButtonKey = Key('sign-out');

  Future<void> _showSignInError(BuildContext context, FirebaseException exception) async {
    await showExceptionAlertDialog(
      context: context,
      title: 'Sign in failed',
      exception: exception,
    );
  }

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    final navigator = Navigator.of(context);
    await EmailPasswordSignInPage.show(
      context,
      onSignedIn: () {
        navigator.pushNamed(HomeScreenBuilder.routeName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (manager.auth.isSignedIn()) {
      final FluggleUser user = Provider.of<FluggleUser>(context, listen: false);

      debugPrint('user: ${user.toString()}');
      return Scaffold(
        appBar: customAppBar(title: title),
        body: _buildSignOut(context, user: user),
      );
    } else {
      return Scaffold(appBar: customAppBar(title: title), body: _buildSignIn(context));
    }
  }

  Widget _buildHeader({FluggleUser? user}) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      _getHeaderText(user: user),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
    );
  }

  String _getHeaderText({FluggleUser? user}) {
    return user != null ? 'Signed In as ${user.displayName}' : 'Sign Out';
  }

  Widget _buildSignOut(BuildContext context, {FluggleUser? user}) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 32.0),
            SizedBox(
              height: 50.0,
              child: _buildHeader(user: user),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              key: signOutButtonKey,
              child: Text(Strings.signOut),
              onPressed: () {
                if (!isLoading) {
                  _signOut(context);
                }
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    // Make content scrollable so that it fits on small screens
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 32.0),
            SizedBox(
              height: 50.0,
              child: _buildHeader(),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              key: emailPasswordButtonKey,
              child: Text(Strings.signInWithEmailPassword),
              onPressed: () {
                if (!isLoading) {
                  _signInWithEmailAndPassword(context);
                }
              },
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
}
