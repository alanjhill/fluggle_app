import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FluggleAppUser _userFromFirebase(User? user) {
    return FluggleAppUser(
      uid: user!.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  @override
  Stream<FluggleAppUser> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<FluggleAppUser> signInAnonymously() async {
    final UserCredential userCredential = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<FluggleAppUser> signInWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(EmailAuthProvider.credential(
      email: email,
      password: password,
    ));
    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<FluggleAppUser> createUserWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(userCredential.user);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<FluggleAppUser> signInWithEmailAndLink({required String email, required String link}) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailLink(email: email, emailLink: link);
    return _userFromFirebase(userCredential.user);
  }

  @override
  bool isSignInWithEmailLink(String link) {
    return _firebaseAuth.isSignInWithEmailLink(link);
  }

  @override
  Future<void> sendSignInWithEmailLink({
    required String email,
    required String url,
    required bool handleCodeInApp,
    required String iOSBundleId,
    required String androidPackageName,
    required bool androidInstallApp,
    required String androidMinimumVersion,
  }) async {
    return await _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: ActionCodeSettings(
        url: url,
        handleCodeInApp: handleCodeInApp,
        iOSBundleId: iOSBundleId,
        androidPackageName: androidPackageName,
        androidInstallApp: androidInstallApp,
        androidMinimumVersion: androidMinimumVersion,
      ),
    );
  }

  @override
  Future<FluggleAppUser> currentUser() async {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}
}
