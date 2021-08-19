import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  Future<void> createUser(BuildContext context, {required User user}) async {
    final firestoreDatabase = context.read(databaseProvider);
    AppUser appUser = AppUser(uid: user.uid, displayName: user.displayName, email: user.email, photoURL: user.photoURL);
    await firestoreDatabase.createAppUser(appUser: appUser);
    return;
  }

  Future<void> updateUser(BuildContext context, {required User user}) async {
    final firestoreDatabase = context.read(databaseProvider);
    AppUser appUser = AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
    );
    await firestoreDatabase.updateAppUser(appUser: appUser);
    return;
  }
}
