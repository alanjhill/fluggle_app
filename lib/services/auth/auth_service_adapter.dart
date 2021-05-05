import 'dart:async';

import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'firebase_auth_service.dart';
import 'mock_auth_service.dart';

enum AuthServiceType { firebase, mock }

class AuthServiceAdapter implements AuthService {
  AuthServiceAdapter({required AuthServiceType initialAuthServiceType}) : authServiceTypeNotifier = ValueNotifier<AuthServiceType>(initialAuthServiceType) {
    _setup();
  }
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final MockAuthService _mockAuthService = MockAuthService();

  // Value notifier used to switch between [FirebaseAuthService] and [MockAuthService]
  final ValueNotifier<AuthServiceType> authServiceTypeNotifier;
  AuthServiceType get authServiceType => authServiceTypeNotifier.value;
  AuthService get authService => authServiceType == AuthServiceType.firebase ? _firebaseAuthService : _mockAuthService;

  StreamSubscription<FluggleUser>? _firebaseAuthSubscription;
  StreamSubscription<FluggleUser>? _mockAuthSubscription;

  void _setup() {
    // Observable<User>.merge was considered here, but we need more fine grained control to ensure
    // that only events from the currently active service are processed
    _firebaseAuthSubscription = _firebaseAuthService.onAuthStateChanged.listen((FluggleUser user) {
      if (authServiceType == AuthServiceType.firebase) {
        _onAuthStateChangedController.add(user);
      }
    }, onError: (dynamic error) {
      if (authServiceType == AuthServiceType.firebase) {
        _onAuthStateChangedController.addError(error);
      }
    });
    _mockAuthSubscription = _mockAuthService.onAuthStateChanged.listen((FluggleUser user) {
      if (authServiceType == AuthServiceType.mock) {
        _onAuthStateChangedController.add(user);
      }
    }, onError: (dynamic error) {
      if (authServiceType == AuthServiceType.mock) {
        _onAuthStateChangedController.addError(error);
      }
    });
  }

  @override
  void dispose() {
    _firebaseAuthSubscription?.cancel();
    _mockAuthSubscription?.cancel();
    _onAuthStateChangedController.close();
    _mockAuthService.dispose();
    authServiceTypeNotifier.dispose();
  }

  final StreamController<FluggleUser> _onAuthStateChangedController = StreamController<FluggleUser>.broadcast();
  @override
  Stream<FluggleUser> get onAuthStateChanged => _onAuthStateChangedController.stream;

  @override
  Future<FluggleUser> currentUser() => authService.currentUser();

/*  @override
  Future<FluggleUser> signInAnonymously() => authService.signInAnonymously();*/

  @override
  Future<FluggleUser> createUserWithEmailAndPassword(String email, String password) => authService.createUserWithEmailAndPassword(email, password);

  @override
  Future<FluggleUser> signInWithEmailAndPassword(String email, String password) => authService.signInWithEmailAndPassword(email, password);

  @override
  Future<void> sendPasswordResetEmail(String email) => authService.sendPasswordResetEmail(email);

  @override
  bool isSignedIn() => authService.isSignedIn();

/*  @override
  Future<FluggleUser> signInWithEmailAndLink({required String email, required String link}) => authService.signInWithEmailAndLink(email: email, link: link);*/

/*  @override
  bool isSignInWithEmailLink(String link) => authService.isSignInWithEmailLink(link);*/

/*  @override
  Future<void> sendSignInWithEmailLink({
    required String email,
    required String url,
    required bool handleCodeInApp,
    required String iOSBundleId,
    required String androidPackageName,
    required bool androidInstallApp,
    required String androidMinimumVersion,
  }) =>
      authService.sendSignInWithEmailLink(
        email: email,
        url: url,
        handleCodeInApp: handleCodeInApp,
        iOSBundleId: iOSBundleId,
        androidPackageName: androidPackageName,
        androidInstallApp: androidInstallApp,
        androidMinimumVersion: androidMinimumVersion,
      );*/

/*  @override
  Future<FluggleUser> signInWithFacebook() => authService.signInWithFacebook();

  @override
  Future<FluggleUser> signInWithGoogle() => authService.signInWithGoogle();

  @override
  Future<FluggleUser> signInWithApple({List<Scope> scopes}) => authService.signInWithApple();*/

  @override
  Future<void> signOut() => authService.signOut();
}
