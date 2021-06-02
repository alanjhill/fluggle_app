import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  ThemeData getThemeData(BuildContext context) {
    return ThemeData(
      cardTheme: CardTheme(
        margin: EdgeInsets.only(top: 6.0, bottom: 6.0),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2.0, style: BorderStyle.solid, color: Colors.white),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          side: BorderSide(width: 2.0, style: BorderStyle.solid, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2.0, style: BorderStyle.solid, color: Colors.white),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 36.0,
      ),
      appBarTheme: AppBarTheme(
        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontSizeFactor: 1.2,
          displayColor: Colors.white,
          bodyColor: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.varelaRoundTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        fontSizeFactor: 1.2,
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),
      brightness: Brightness.light,
      canvasColor: kFlugglePrimaryColor,
    );
  }
}
