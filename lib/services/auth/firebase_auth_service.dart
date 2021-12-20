import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AppUser _userFromFirebase(User? user) {
    return AppUser(
      uid: user!.uid,
      displayName: user.displayName ?? '',
      email: user.email,
      photoURL: user.photoURL,
    );
  }

/*  @override
  Stream<AppUser> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }*/

  //@override
  Future<AppUser> signInAnonymously() async {
    final UserCredential userCredential = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({required String email, required String password}) async {
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(EmailAuthProvider.credential(
      email: email,
      password: password,
    ));

    String uid = userCredential.user!.uid;
    Future<AppUser> fluggleUser = FirestoreDatabase(uid: uid).getUser(uid: uid);
    return fluggleUser;
  }

  @override
  Future<AppUser> createUserWithEmailAndPassword({required String email, required String password}) async {
    final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    // Create user in Firestore
    String uid = userCredential.user!.uid;
    AppUser user = AppUser(uid: uid, email: userCredential.user!.email, displayName: userCredential.user!.email!);
    await FirestoreDatabase(uid: uid).updateUserData(user: user);

    return _userFromFirebase(userCredential.user);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  AppUser? get fluggleUser {
    currentUser().then((fluggleUser) {
      return fluggleUser;
    });

    return null;
  }

  @override
  Future<AppUser> currentUser() async {
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
