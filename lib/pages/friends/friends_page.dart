import 'package:fluggle_app/common_widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/models/user/friend_list_view_model.dart';
import 'package:fluggle_app/models/user/user_friend.dart';
import 'package:fluggle_app/pages/friends/friends_list.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// >>> Providers
final friendsStreamProvider = StreamProvider.autoDispose<List<AppUserFriend>>(
  (ref) {
    final database = ref.watch(databaseProvider);
    final vm = FriendListViewModel(database: database);
    return vm.userFriendsStream();
  },
);

/// <<< end Providers

class FriendsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    //final mediaQuery = MediaQuery.of(context);
    //final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;
    final PreferredSizeWidget appBar = CustomAppBar(title: Text(Strings.friendsPage));
    final friendsListAsyncValue = watch(friendsStreamProvider);

    void _addFriend() {
      Navigator.of(context).pushNamed(AppRoutes.friendsSearchPage);
    }

    final buttonsWidget = Container(
      //height: remainingHeight * 0.2,
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //SizedBox(height: 8.0),
          CustomRaisedButton(
            child: Text('Add Friend'),
            onPressed: () => _addFriend(),
          ),
          //SizedBox(height: 8.0),
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  buttonsWidget,
                  FriendsList(data: friendsListAsyncValue),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
