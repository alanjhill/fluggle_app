import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  final Text title;
  final Widget? leading;
  final List<Widget>? actions;

  CustomAppBar({Key? key, required this.title, this.leading, this.actions})
      : preferredSize = Size.fromHeight(50.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title.data.toString().toUpperCase(),
      ),
      centerTitle: true,
      leading: this.leading ?? null,
      actions: this.actions ?? null,
    );
  }
}
