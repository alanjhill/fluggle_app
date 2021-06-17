class AppUser {
  AppUser({required this.uid, required this.displayName, this.email, this.photoURL, this.admin = false});
  final String uid;
  final String displayName;
  final String? email;
  final String? photoURL;
  final bool? admin;

  // Not persisted
  List<AppUser> friends = [];

  factory AppUser.fromMap(Map<String, dynamic> map, String documentId) {
    return AppUser(
      uid: documentId,
      displayName: map['displayName'],
      email: map['email'],
      photoURL: map['photoURL'],
      admin: map['admin'] != null ? map['admin'] : false,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'admin': admin,
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
          photoURL == other.photoURL &&
          admin == other.admin;

  @override
  int get hashCode => uid.hashCode ^ displayName.hashCode ^ email.hashCode ^ photoURL.hashCode ^ admin.hashCode;
}
