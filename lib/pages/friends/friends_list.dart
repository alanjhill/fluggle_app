import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/common_widgets/list_items_builder.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/pages/friends/friend_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsList extends StatelessWidget {
  FriendsList({Key? key, required this.data}) : super(key: key);
  final AsyncValue<List<AppUserFriend>> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        child: ListItemsBuilder<AppUserFriend>(
          data: data,
          itemBuilder: (context, appUserFriend) => FriendItem(appUserFriend: appUserFriend),
        ),
      ),
    );
  }
}

class Record {
  final String? displayName;
  final DocumentReference? reference;

  Record.fromMap(Map<String, dynamic>? map, {this.reference})
      : assert(map!['display_name'] != null),
        displayName = map!['display_name'];

  Record.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data() as Map<String, dynamic>?, reference: snapshot.reference);
}
