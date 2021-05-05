import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/user/friend_list_view_model.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/screens/friends/friend_item.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FriendsList extends StatelessWidget {
  static Widget create(BuildContext context) {
    final database = Provider.of<FirestoreDatabase>(context, listen: false);
    return Provider<FriendListViewModel>(
      create: (_) => FriendListViewModel(database: database),
      child: FriendsList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SafeArea(
      child: _build(context),
    ));
  }

  @override
  Widget _build(BuildContext context) {
    final viewModel = Provider.of<FriendListViewModel>(context, listen: false);
    return StreamBuilder<List<UserFriend?>>(
      stream: viewModel.userFriendsStream(),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          final userFriends = snapshot.data;
          if (userFriends == null) {
            return Text('You have no friends', style: Theme.of(context).textTheme.headline6);
          }
          return _buildFriendList(context, snapshot.data);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildFriendList(BuildContext context, fluggleUserFriends) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      itemCount: fluggleUserFriends.length,
      itemBuilder: (context, index) => _buildListItem(
        context,
        fluggleUserFriends[index],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, UserFriend userFriend) {
    return FriendItem(friend: userFriend.user);
  }
}

class Record {
  final String? displayName;
  final DocumentReference? reference;

  Record.fromMap(Map<String, dynamic>? map, {this.reference})
      : assert(map!['display_name'] != null),
        displayName = map!['display_name'];

  Record.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data(), reference: snapshot.reference);
}
