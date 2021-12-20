import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluggle_app/models/user/app_user.dart';
import 'package:fluggle_app/widgets/reusable_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsSearchItem extends ConsumerWidget {
  const FriendsSearchItem({
    Key? key,
    required this.appUser,
    required this.addFriend,
  }) : super(key: key);

  final AppUser appUser;
  final Function addFriend;

  @override
  build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      child: ReusableCard(
        key: Key('cart-${appUser.uid}'),
        cardChild: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: AutoSizeText(
                appUser.email!,
                wrapWords: false,
              ),
              subtitle: AutoSizeText(
                appUser.displayName!,
                wrapWords: false,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 32.0,
                  color: Colors.white,
                ),
                onPressed: () async {
                  debugPrint('Add Friend');
                  await addFriend(context, ref, friendId: appUser.uid);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        //_playGameButtonPressed(context, game: game);
      },
    );
  }
}
