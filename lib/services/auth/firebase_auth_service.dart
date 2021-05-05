import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FluggleUser _userFromFirebase(User? user) {
    return FluggleUser(
      uid: user!.uid,
      displayName: user.displayName ?? '',
      email: user.email,
      photoURL: user.photoURL,
    );
  }

  @override
  Stream<FluggleUser> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<FluggleUser> signInAnonymously() async {
    final UserCredential userCredential = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<FluggleUser> signInWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(EmailAuthProvider.credential(
      email: email,
      password: password,
    ));

    String uid = userCredential.user!.uid;
    return FirestoreDatabase(uid: uid).getUser(uid: uid);
    //return user;
    //return _userFromFirebase(userCredential.user);
  }

  @override
  Future<FluggleUser> createUserWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    // Create user in Firestore
    String uid = userCredential.user!.uid;
    FluggleUser user = FluggleUser(uid: uid, email: userCredential.user!.email, displayName: userCredential.user!.email!);
    await FirestoreDatabase(uid: uid).updateUserData(user: user);

    return _userFromFirebase(userCredential.user);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<FluggleUser> currentUser() async {
    return _userFromFirebase(_firebaseAuth.currentUser!);
  }

  @override
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}
}
