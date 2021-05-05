import 'dart:async';

import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:meta/meta.dart';

abstract class AuthService {
  Future<FluggleUser> currentUser();
  //Future<FluggleUser> signInAnonymously();
  Future<FluggleUser> signInWithEmailAndPassword(String email, String password);
  Future<FluggleUser> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  /*Future<FluggleUser> signInWithEmailAndLink({required String email, required String link});
  bool isSignInWithEmailLink(String link);
  Future<void> sendSignInWithEmailLink({
    required String email,
    required String url,
    required bool handleCodeInApp,
    required String iOSBundleId,
    required String androidPackageName,
    required bool androidInstallApp,
    required String androidMinimumVersion,
  });*/
  //Future<FluggleUser> signInWithGoogle();
  //Future<FluggleUser> signInWithFacebook();
  //Future<MyAppUser> signInWithApple({List<Scope> scopes});
  bool isSignedIn();
  Future<void> signOut();
  Stream<FluggleUser> get onAuthStateChanged;
  void dispose();
}
