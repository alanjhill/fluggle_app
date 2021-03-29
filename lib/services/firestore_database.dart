import 'dart:async';

import 'package:fluggle_app/models/friend.dart';
import 'package:fluggle_app/models/user.dart';
import 'package:fluggle_app/services/firestore_path.dart';
import 'package:fluggle_app/services/firestore_service.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class FirestoreDatabase {
  final String uid;

  FirestoreDatabase({required this.uid})
      : assert(
          uid != null,
        );

  final _service = FirestoreService.instance;

  Stream<List<Friend>> friendsStream() => _service.collectionStream<Friend>(
        path: FirestorePath.friends(uid),
        builder: (data, documentId) => Friend.fromMap(data!, documentId),
      );

  Stream<List<User>> userStream(String friendId) => _service.collectionStream<User>(
        path: FirestorePath.user(friendId),
        builder: (data, documentId) => User.fromMap(data!, documentId),
      );

  Stream<List<User>> usersStream() => _service.collectionStream<User>(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data!, documentId),
      );
}
