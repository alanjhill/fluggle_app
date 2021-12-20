import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateChangesProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final databaseProvider = Provider<FirestoreDatabase?>(
  (ref) {
    final auth = ref.watch(authStateChangesProvider);

    if (auth.asData?.value?.uid != null) {
      return FirestoreDatabase(uid: auth.data!.value!.uid);
    }
    return null;
    //throw UnimplementedError();
  },
);

final loggerProvider = Provider<Logger>(
  (ref) => Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      printEmojis: false,
    ),
  ),
);
