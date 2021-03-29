import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluggle_app/models/friend_list_view_model.dart';
import 'package:fluggle_app/models/user_friend.dart';
import 'package:fluggle_app/services/firestore_database.dart';
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
      child: _buildFriendList(context),
    ));
  }

  @override
  Widget _buildFriendList(BuildContext context) {
    final viewModel = Provider.of<FriendListViewModel>(context, listen: false);
    return StreamBuilder<List<UserFriend>>(
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
          return _buildList(context, snapshot.data);
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

  Widget _buildList(BuildContext context, fluggleUserFriends) {
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
    return Padding(
      key: ValueKey(userFriend.friend.id),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          trailing: Text(userFriend.user!.displayName),
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

  Record.fromSnapshot(DocumentSnapshot? snapshot) : this.fromMap(snapshot!.data(), reference: snapshot.reference);
}
