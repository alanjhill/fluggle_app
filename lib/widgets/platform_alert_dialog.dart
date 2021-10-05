import 'package:fluggle_app/constants/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'platform_widget.dart';

class PlatformAlertDialog extends PlatformWidget {
  const PlatformAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    this.cancelActionText,
    required this.defaultActionText,
  }) : super(key: key);

  final String title;
  final String content;
  final String? cancelActionText;
  final String defaultActionText;

  Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => this,
    );
  }

  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        PlatformAlertDialogAction(
          child: Text(
            cancelActionText!,
            key: const Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
        child: Text(
          defaultActionText,
          key: const Key(Keys.alertDefault),
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  const PlatformAlertDialogAction({Key? key, this.child, this.onPressed})
      : super(key: key);
  final Widget? child;
  final VoidCallback? onPressed;

/*  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }*/

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return TextButton(
      child: child!,
      onPressed: onPressed,
    );
  }
}
