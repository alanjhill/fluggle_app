import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  ThemeData getThemeData(BuildContext context) {
    return ThemeData(
      textTheme: GoogleFonts.varelaRoundTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        fontSizeFactor: 1.3,
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),
      primaryTextTheme: GoogleFonts.varelaRoundTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        fontSizeFactor: 1.2,
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),
      accentTextTheme: GoogleFonts.varelaRoundTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        fontSizeFactor: 1.2,
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: kFlugglePrimaryColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2.0, style: BorderStyle.solid, color: Colors.white),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: Colors.blue,
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 36.0,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: kFlugglePrimaryColor,
        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontSizeFactor: 1.25,
          displayColor: Colors.white,
          bodyColor: Colors.white,
        ),
      ),
      brightness: Brightness.light,
      canvasColor: kFlugglePrimaryColor,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white),
        helperStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFluggleSecondaryColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorStyle: TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
