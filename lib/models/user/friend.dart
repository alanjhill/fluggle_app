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
  bool operator ==(Object other) => identical(this, other) || other is Friend && runtimeType == other.runtimeType && friendId == other.friendId && friendStatus == other.friendStatus;

  @override
  int get hashCode => friendId.hashCode ^ friendStatus.hashCode;

  @override
  String toString() {
    return 'Friend<friendId:$friendId,friendStatus:$friendStatus>';
  }
}
