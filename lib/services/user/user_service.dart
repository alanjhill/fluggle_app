import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) => throw UnimplementedError());

class UserService {
  Future<void> createUser(WidgetRef ref, {required User user}) async {
    final firestoreDatabase = ref.read(databaseProvider);
    AppUser appUser = AppUser(uid: user.uid, displayName: user.displayName, email: user.email, photoURL: user.photoURL);
    await firestoreDatabase!.createAppUser(appUser: appUser);
  }

  Future<void> updateUser(WidgetRef ref, {required User user}) async {
    final firestoreDatabase = ref.read(databaseProvider);
    AppUser appUser = AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL,
    );
    await firestoreDatabase!.updateAppUser(appUser: appUser);
  }
}
