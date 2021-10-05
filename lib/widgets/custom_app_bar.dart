import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String titleText;
  final Widget? leading;
  final List<Widget> actions;

  CustomAppBar(
      {Key? key,
      required this.titleText,
      this.leading,
      this.actions = const []})
      : preferredSize = const Size.fromHeight(80.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      leadingWidth: 48.0,
      centerTitle: true,
      title: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: AutoSizeText(
              titleText.toUpperCase(),
              maxLines: 1,
              textAlign: TextAlign.start,
              maxFontSize: 22.0,
              //style: TextStyle(fontSize)
            ),
          );
        },
      ),
      actions: actions,
      //leadingWidth: 32.0,
    );
  }
}
