import 'dart:async';

import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:flutter/services.dart';

import 'package:random_string/random_string.dart' as random;

/// Mock authentication service to be used for testing the UI
/// Keeps an in-memory store of registered accounts so that registration and sign in flows can be tested.
class MockAuthService implements AuthService {
  MockAuthService({
    this.startupTime = const Duration(milliseconds: 250),
    this.responseTime = const Duration(seconds: 2),
  }) {
    Future<void>.delayed(responseTime!).then((_) {
      _add(null);
    });
  }
  final Duration? startupTime;
  final Duration? responseTime;

  final Map<String, _UserData> _usersStore = <String, _UserData>{};

  FluggleUser? _currentUser;

  final StreamController<FluggleUser> _onAuthStateChangedController = StreamController<FluggleUser>();
  @override
  Stream<FluggleUser> get onAuthStateChanged => _onAuthStateChangedController.stream;

  @override
  Future<FluggleUser> currentUser() async {
    await Future<void>.delayed(startupTime!);
    return _currentUser!;
  }

  @override
  Future<FluggleUser> createUserWithEmailAndPassword(String email, String password) async {
    await Future<void>.delayed(responseTime!);
    if (_usersStore.keys.contains(email)) {
      throw PlatformException(
        code: 'ERROR_EMAIL_ALREADY_IN_USE',
        message: 'The email address is already registered. Sign in instead?',
      );
    }
    final FluggleUser user = FluggleUser(uid: random.randomAlphaNumeric(32), displayName: 'Fluggle User', email: email);
    _usersStore[email] = _UserData(password: password, user: user);
    _add(user);
    return user;
  }

  @override
  Future<FluggleUser> signInWithEmailAndPassword(String email, String password) async {
    await Future<void>.delayed(responseTime!);
    if (!_usersStore.keys.contains(email)) {
      throw PlatformException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'The email address is not registered. Need an account?',
      );
    }
    final _UserData? _userData = _usersStore[email];
    if (_userData!.password != password) {
      throw PlatformException(
        code: 'ERROR_WRONG_PASSWORD',
        message: 'The password is incorrect. Please try again.',
      );
    }
    _add(_userData.user);
    return _userData.user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  bool isSignedIn() {
    return true;
  }

  @override
  Future<void> signOut() async {
    _add(null);
  }

  void _add(FluggleUser? user) {
    _currentUser = user;
    _onAuthStateChangedController.add(user!);
  }

  @override
  void dispose() {
    _onAuthStateChangedController.close();
  }
}

class _UserData {
  _UserData({required this.password, required this.user});
  final String password;
  final FluggleUser user;
}
