import 'package:fluggle_app/constants.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({required String title, bool centerTitle = false, List<Widget>? actions = const []}) {
  return AppBar(
    elevation: 2.0,
    title: Text(title),
    centerTitle: centerTitle,
    backgroundColor: kFlugglePrimaryColor,
    actions: actions,
  );
}
