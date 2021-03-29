import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendStatus {
  invited,
  accepted,
  decined,
}

class Friend {
  Friend({required this.id, required this.uid, this.status = FriendStatus.invited});

  final String id;
  final String uid;
  final FriendStatus status;

  factory Friend.fromMap(Map<String, dynamic> map, String documentId) {
    return Friend(id: documentId, uid: map['uid'], status: map['status']);
  }

  //Friend.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data(), reference: snapshot.reference);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
    };
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Friend otherFriend = other;
    return id == otherFriend.id && uid == otherFriend.uid && status == otherFriend.status;
  }

  @override
  String toString() {
    return 'Friend<id:$id,uid:$uid,status:$status>';
  }
}
