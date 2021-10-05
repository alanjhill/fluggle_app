import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
abstract class PlatformWidget extends StatelessWidget {
  const PlatformWidget({Key? key}) : super(key: key);

  //Widget buildCupertinoWidget(BuildContext context);
  Widget buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
/*    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    }*/
    return buildMaterialWidget(context);
  }
}
