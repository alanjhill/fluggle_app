import 'dart:async';

import 'package:fluggle_app/models/user/app_user.dart';

abstract class AuthService {
  Future<AppUser> currentUser();
  Future<AppUser> signInWithEmailAndPassword({required String email, required String password});
  Future<AppUser> createUserWithEmailAndPassword({required String email, required String password});
  Future<void> sendPasswordResetEmail({required String email});
  bool isSignedIn();
  Future<void> signOut();
  //Stream<AppUser> get onAuthStateChanged;
  void dispose();
}
