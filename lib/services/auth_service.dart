import 'dart:async';

import 'package:meta/meta.dart';

@immutable
class FluggleAppUser {
  const FluggleAppUser({
    required this.uid,
    this.email,
    this.photoURL,
    this.displayName,
  });

  final String uid;
  final String? email;
  final String? photoURL;
  final String? displayName;
}

abstract class AuthService {
  Future<FluggleAppUser> currentUser();
  Future<FluggleAppUser> signInAnonymously();
  Future<FluggleAppUser> signInWithEmailAndPassword(String email, String password);
  Future<FluggleAppUser> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<FluggleAppUser> signInWithEmailAndLink({required String email, required String link});
  bool isSignInWithEmailLink(String link);
  Future<void> sendSignInWithEmailLink({
    required String email,
    required String url,
    required bool handleCodeInApp,
    required String iOSBundleId,
    required String androidPackageName,
    required bool androidInstallApp,
    required String androidMinimumVersion,
  });
  //Future<FluggleAppUser> signInWithGoogle();
  //Future<FluggleAppUser> signInWithFacebook();
  //Future<MyAppUser> signInWithApple({List<Scope> scopes});
  Future<void> signOut();
  Stream<FluggleAppUser> get onAuthStateChanged;
  void dispose();
}
