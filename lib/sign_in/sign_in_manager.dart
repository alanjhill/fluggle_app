import 'dart:async';

import 'package:fluggle_app/services/auth_service.dart';
import 'package:fluggle_app/services/firebase_auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

class SignInManager {
  SignInManager({required this.auth, required this.isLoading});
  final FirebaseAuthService auth;
  final ValueNotifier<bool> isLoading;

  Future<FluggleAppUser> _signIn(Future<FluggleAppUser> Function() signInMethod) async {
    try {
      isLoading.value = true;
      return await signInMethod();
    } catch (e) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<FluggleAppUser> signInAnonymously() async {
    return await _signIn(auth.signInAnonymously);
  }
}
