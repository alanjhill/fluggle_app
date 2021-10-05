import 'package:fluggle_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
/*      accentTextTheme: GoogleFonts.varelaRoundTextTheme(
        Theme.of(context).textTheme,
      ).apply(
        fontSizeFactor: 1.2,
        displayColor: Colors.white,
        bodyColor: Colors.white,
      ),*/
      dialogTheme: const DialogTheme(
        backgroundColor: kFluggleDarkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
      cardTheme: const CardTheme(
        color: kFluggleDarkColor,
        elevation: 3,
        margin: EdgeInsets.all(0.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: kFluggleLightColor,
          elevation: 2,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: kFluggleLightColor,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 36.0,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: kFluggleCanvasColor,
            statusBarIconBrightness: Brightness.light),
        backgroundColor: kFluggleCanvasColor,
/*        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontSizeFactor: 1.25,
          displayColor: Colors.white,
          bodyColor: Colors.white,
        ),*/
      ),
      canvasColor: kFluggleCanvasColor,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white),
        helperStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: kFluggleLightColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorStyle: TextStyle(color: Colors.redAccent),
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        color: Colors.white,
        hoverColor: kFluggleDarkColor,
        borderRadius: BorderRadius.circular(0),
        fillColor: Colors.transparent,
        selectedColor: kFluggleDarkColor,
      ),
    );
  }
}
