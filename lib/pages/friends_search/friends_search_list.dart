import 'package:fluggle_app/widgets/list_items_builder.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/pages/friends_search/friends_search_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsSearchList extends StatelessWidget {
  FriendsSearchList({Key? key, required this.data, required this.addFriend}) : super(key: key);

  final Function addFriend;
  final AsyncValue<List<AppUser>> data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ListItemsBuilder<AppUser>(data: data, itemBuilder: (context, appUser) => FriendsSearchItem(appUser: appUser, addFriend: addFriend)));
  }
}
