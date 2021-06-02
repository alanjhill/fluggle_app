class AppUser {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoURL;

  // Not persisted
  List<AppUser> friends = [];

  AppUser({required this.uid, required this.displayName, this.email, this.photoURL});

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(uid: documentId, displayName: map['displayName'], email: map['email'], photoURL: map['photoURL']);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
    };

    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          displayName == other.displayName &&
          email == other.email &&
          photoURL == other.photoURL;

  @override
  int get hashCode => uid.hashCode ^ displayName.hashCode ^ email.hashCode ^ photoURL.hashCode;
}
