import 'package:fluggle_app/constants.dart';
import 'package:flutter/material.dart';

class ScoresScreen extends StatefulWidget {
  static const String routeName = "/scores";

  @override
  _ScoresScreenState createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kFlugglePrimaryColor,
        title: const Text('Fluggle'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Scores'),
          ],
        ),
      ),
    );
  }
}
