import 'package:flutter/material.dart';

@immutable
class FluggleUser {
  const FluggleUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoURL,
  });

  final String uid;
  final String displayName;
  final String? email;
  final String? photoURL;

  factory FluggleUser.fromMap(Map<String, dynamic> map, String documentId) {
    return FluggleUser(
      uid: documentId,
      displayName: map['displayName'],
      email: map['email'],
      photoURL: map['photoURL'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final FluggleUser otherUser = other;
    return uid == otherUser.uid && displayName == otherUser.displayName && email == otherUser.email && photoURL == otherUser.photoURL;
  }

  @override
  String toString() => "FlugglUser<uid:$uid,displayName:$displayName,email:$email,photoURL:$photoURL>";
}
