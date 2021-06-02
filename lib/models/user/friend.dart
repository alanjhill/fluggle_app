enum FriendStatus {
  requested,
  invited,
  accepted,
  declined,
}

class Friend {
  final String friendId;
  final FriendStatus friendStatus;

  Friend({
    required this.friendId,
    this.friendStatus = FriendStatus.invited,
  });

  factory Friend.fromMap(Map<String, dynamic> map, String documentId) {
    return Friend(
      friendId: documentId,
      friendStatus: FriendStatus.values.firstWhere(
        (status) => status.toString() == map['friendStatus'],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      //'friendId': friendId,
      'friendStatus': friendStatus.toString(),
    };
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Friend otherFriend = other;
    return friendId == otherFriend.friendId && friendStatus == otherFriend.friendStatus;
  }

  @override
  String toString() {
    return 'Friend<friendId:$friendId,friendStatus:$friendStatus>';
  }
}
