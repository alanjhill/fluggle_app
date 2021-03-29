import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/common_widgets/form_submit_button.dart';
import 'package:fluggle_app/common_widgets/show_alert_dialog.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/sign_in/email_link/email_link_sign_in_page.dart';
import 'package:fluggle_app/sign_in/email_password/email_password_sign_in_page.dart';
import 'package:fluggle_app/sign_in/sign_in_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluggle_app/sign_in/sign_in_button.dart';
import 'package:fluggle_app/sign_in/sign_in_view_model.dart';
import 'package:fluggle_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:fluggle_app/services/firebase_auth_service.dart';

class SignInPageBuilder extends StatelessWidget {
  static const String routeName = 'signIn';

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
              title: 'Firebase Auth Demo',
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
      onSignedIn: navigator.pop,
    );
  }

  Future<void> _signInWithEmailLink(BuildContext context) async {
    final navigator = Navigator.of(context);
    await EmailLinkSignInPage.show(
      context,
      onSignedIn: navigator.pop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(title),
      ),
      backgroundColor: Colors.grey[200],
      body: _buildSignIn(context),
    );
  }

  Widget _buildHeader() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Text(
      'Sign in',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
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
            SignInButton(
              key: emailPasswordButtonKey,
              text: Strings.signInWithEmailPassword,
              //onPressed: isLoading ? null : () => _signInWithEmailAndPassword(context),
              onPressed: () {
                if (!isLoading) {
                  _signInWithEmailAndPassword(context);
                }
              },
              textColor: Colors.white,
              color: Colors.teal[700]!,
            ),
            SizedBox(height: 8),
            SignInButton(
              key: emailLinkButtonKey,
              text: Strings.signInWithEmailLink,
              //onPressed: isLoading ? null : () => _signInWithEmailLink(context),
              onPressed: () {
                _signInWithEmailLink(context);
              },
              textColor: Colors.white,
              color: Colors.blueGrey[700]!,
            ),
            SizedBox(height: 8),
            Text(
              Strings.or,
              style: TextStyle(fontSize: 14.0, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

/*  Widget _buildSignIn(BuildContext context) {
    // Make content scrollable so that it fits on small screens
    return Container(
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
          _buildEmailField(),
          SizedBox(height: 8),
          _buildPasswordField(),
          SizedBox(height: 8),
          FormSubmitButton(
            key: Key('primary-button'),
            text: model.primaryButtonText!,
            loading: model.isLoading,
            //onPressed: model.isLoading ? null : _submit,
            onPressed: () {
              if (model.isLoading == false) {
                _submit();
              }
            },
          ),
          SizedBox(height: 8.0),
          TextButton(
              key: Key('secondary-button'),
              child: Text(model.secondaryButtonText!),
              onPressed: () {
                if (!model.isLoading) {
                  _updateFormType(model.secondaryActionFormType!);
                }
              }),
          if (model.formType == EmailPasswordSignInFormType.signIn)
            TextButton(
              key: Key('tertiary-button'),
              child: Text(Strings.forgotPasswordQuestion),
              onPressed: model.isLoading ? null : () => _updateFormType(EmailPasswordSignInFormType.forgotPassword),
            ),
        ],
      ),
    );
  }*/
}
