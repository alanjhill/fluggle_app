import 'package:flutter/material.dart';

class Constants {
  // TODO: Replace this with your firebase project URL
  static const String firebaseProjectURL = 'https://fir-auth-demo-flutter.firebaseapp.com/';
}

const double kGameBoardPadding = 40.0;
const double kCubePadding = 8.0;
const double kCubeSelectedPadding = 5.0;
const double kLetterPadding = 12.0;
const double kFluggleBoardBorderWidth = 2.0;
const double kBottomBarHeight = 64;
const double kScoresColumnPadding = 4.0;
const double kPagePadding = 16.0;
const double kCurrentWordCubeSpacing = 2.0;

const int kGridCount = 4;

//1a73e8
const Color kFlugglePrimaryColor = Color(0xFF1A73E8);
const Color kFluggleLightColor = Color(0xFF69A1FF);
const Color kFluggleDarkColor = Color(0xFF0049B5);
const Color kFluggleCanvasColor = kFlugglePrimaryColor;

const Color kFluggleCubeColor = Color(0xFFFFFDD0);
const Color kFluggleBoardColor = Color.fromRGBO(9, 89, 157, 1);
const Color kFluggleBoardBackgroundColor = Color.fromRGBO(9, 89, 157, 0.2);
const Color kFluggleBoardBorderColor = kFluggleDarkColor;

const Color kFluggleLetterColor = kFlugglePrimaryColor;
const Color kFluggleLetterHighlightColor = kFluggleLightColor;
const Color kFluggleSwipeLineColor = kFluggleLightColor;

const double kSwipeLineWidth = 8.0;

const kTimerTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
  color: kFluggleLightColor,
);

var kElevatedButtonStyle = ElevatedButton.styleFrom(
  elevation: 10,
  primary: kFluggleLightColor,
  padding: EdgeInsets.all(10.0),
);

const kTextFieldDecoration = InputDecoration(
  hintText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
