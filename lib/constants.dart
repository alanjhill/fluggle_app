import 'package:flutter/material.dart';

const int kGAME_TIME = 180;
const double kGAME_BOARD_PADDING = 40.0;
const double kCUBE_PADDING = 8.0;
const double kCUBE_SELECTED_PADDING = 5.0;
const double kLETTER_PADDING = 12.0;
const double kFLUGGLE_BOARD_BORDER_WIDTH = 1.0;
const double kSTATUS_BAR_HEIGHT = 48;

const int kGridCount = 4;

const Color kFlugglePrimaryColor = Color.fromRGBO(0, 89, 157, 1);
const Color kFluggleSecondaryColor = Color.fromRGBO(69, 209, 253, 1);

const Color kFluggleCubeColor = Color(0xfffffdd0);
const Color kFluggleBoardColor = Color.fromRGBO(9, 89, 157, 1); //Color.fromRGBO(69, 209, 253, 1);
const Color kFluggleBoardBackgroundColor = Color.fromRGBO(9, 89, 157, 0.2); //Colors.white; //Color.fromRGBO(9, 89, 157, 0.5);
const Color kFluggleBoardBorderColor = kFluggleSecondaryColor;
const Color kFluggleLetterColor = kFlugglePrimaryColor; //Colors.white;
const Color kFluggleLetterHighlightColor = kFluggleSecondaryColor; //Color.fromRGBO(69, 209, 253, 1);
const Color kFluggleSwipeLineColor = kFluggleSecondaryColor; //kFluggleLetterHighlightColor;

const double kSwipeLineWidth = 8.0;

const kEggTimerTextStyle = TextStyle(
  fontSize: 36.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
  color: Color.fromRGBO(69, 209, 253, 1),
);

var kElevatedButtonStyle = ElevatedButton.styleFrom(
  elevation: 10,
  primary: kFlugglePrimaryColor,
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
