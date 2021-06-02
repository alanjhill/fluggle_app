import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({required String title, bool centerTitle = false, bool backButton = true, List<Widget>? actions = const []}) {
  return AppBar(
    leading: !backButton ? Container() : null,
    elevation: 2.0,
    title: Text(title),
    centerTitle: centerTitle,
    backgroundColor: kFlugglePrimaryColor,
    actions: actions,
  );
}
