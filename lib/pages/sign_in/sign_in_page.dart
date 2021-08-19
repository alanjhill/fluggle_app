import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/alert_dialogs/alert_dialogs.dart';
import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/keys.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/pages/sign_in/sign_in_view_model.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signInModelProvider = ChangeNotifierProvider<SignInViewModel>(
  (ref) => SignInViewModel(auth: ref.watch(firebaseAuthProvider)),
);

class SignInPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final signInModel = watch(signInModelProvider);
    return ProviderListener<SignInViewModel>(
      provider: signInModelProvider,
      onChange: (context, model) async {
        if (model.error != null) {
          await showExceptionAlertDialog(
            context: context,
            title: Strings.signInFailed,
            exception: model.error,
          );
        }
      },
      child: SignInPageContents(
        viewModel: signInModel,
        title: Strings.signIn,
      ),
    );
  }
}

class SignInPageContents extends StatelessWidget {
  const SignInPageContents({Key? key, required this.viewModel, this.title = Strings.signIn}) : super(key: key);
  final SignInViewModel viewModel;
  final String title;

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key anonymousButtonKey = Key(Keys.anonymous);

  Future<void> _showEmailPasswordSignInPage(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.pushNamed(AppRoutes.emailPasswordSignInPage, arguments: () {
      //navigator.pop();
      navigator.pushReplacementNamed(AppRoutes.homePage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: title,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: _buildSignIn(context),
          ),
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: min(constraints.maxWidth, 600),
          //padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CustomRaisedButton(
                key: emailPasswordButtonKey,
                child: AutoSizeText(Strings.signInWithEmailPassword),
                textColor: Colors.white,
                onPressed: viewModel.isLoading ? null : () => _showEmailPasswordSignInPage(context),
              ),
              const SizedBox(height: 8),
              const AutoSizeText(
                Strings.or,
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              CustomRaisedButton(
                  key: anonymousButtonKey,
                  child: Text(Strings.goAnonymous),
                  textColor: Colors.white,
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          await viewModel.signInAnonymously();
                          Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
                        }),
            ],
          ),
        );
      },
    );
  }
}
