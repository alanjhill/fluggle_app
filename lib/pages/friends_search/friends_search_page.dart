import 'package:fluggle_app/widgets/custom_app_bar.dart';
import 'package:fluggle_app/constants/strings.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/models/user/user_view_model.dart';
import 'package:fluggle_app/pages/friends_search/friends_search_list.dart';
import 'package:fluggle_app/services/friends/friends_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// >>> Providers
final userViewModelStreamProvider = StreamProvider.autoDispose.family<List<AppUser>, String>(
  (ref, email) {
    final database = ref.watch(databaseProvider);
    final vm = UserViewModel(database: database!);
    return vm.findUsersByEmail(email: email);
  },
);

/// <<< end Providers

// ignore: must_be_immutable
class FriendsSearchPage extends ConsumerWidget {
  String email = '';
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = CustomAppBar(titleText: Strings.addFriendPage);
    final remainingHeight = mediaQuery.size.height - appBar.preferredSize.height - mediaQuery.padding.top;

    final friendsSearchAsyncValue = ref.watch(userViewModelStreamProvider(email));

    Widget _buildFindFriendsListWidget(BuildContext context) {
      return Container(
        padding: EdgeInsets.only(bottom: 16.0),
        height: remainingHeight * 0.8,
        child: FriendsSearchList(data: friendsSearchAsyncValue, addFriend: _addFriend),
      );
    }

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
                  //buttonsWidget,
                  TextField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    controller: _emailController,
                    onSubmitted: (_) => _searchByEmail(),
                    // onChanged: (val) {
                    //   titleInput = val;
                    // },
                  ),
                  _buildFindFriendsListWidget(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addFriend(WidgetRef ref, {required String friendId}) async {
    final friendsService = ref.read(friendsServiceProvider);
    await friendsService.addFriend(ref, friendId: friendId);
  }

  void _searchByEmail() {
    debugPrint('searchByEmail');
    email = _emailController.text;
  }
}
