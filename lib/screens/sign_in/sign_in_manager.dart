import 'dart:async';

import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class SignInManager {
  SignInManager({required this.auth, required this.isLoading});
  final FirebaseAuthService auth;
  final ValueNotifier<bool> isLoading;

  Future<FluggleUser> _signIn(Future<FluggleUser> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<FluggleUser> signInAnonymously() async {
    return await _signIn(auth.signInAnonymously);
  }

  Future<void> signOut() async {
    return await auth.signOut();
  }
}
