import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/friend.dart';
import 'package:flutter/material.dart';

class User {
  User({required this.uid, required this.displayName});

  final String uid;
  final String displayName;

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(uid: documentId, displayName: map['displayName']);

    //User.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data(), reference: snapshot.reference);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
    };
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final User otherUser = other;
    return uid == otherUser.uid && displayName == otherUser.displayName;
  }

  @override
  String toString() => "FlugglUser<uid:$uid,displayName:$displayName>";
}
