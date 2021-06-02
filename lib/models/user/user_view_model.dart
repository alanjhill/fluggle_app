import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';

class UserViewModel {
  UserViewModel({required this.database});

  final FirestoreDatabase database;

  Stream<List<AppUser>> findUsersByEmail({required String email}) {
    return database.findUsersByEmailStream(email: email);
  }

  Stream<AppUser> findUserByUid({required String uid}) {
    return database.appUserStream(uid: uid);
  }
}
