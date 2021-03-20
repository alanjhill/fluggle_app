import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/game_screen.dart';
import 'package:fluggle_app/screens/home_screen.dart';
import 'package:fluggle_app/screens/scores_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeliMeals',
      theme: ThemeData(
        //primarySwatch: kFlugglePrimaryColor,
        //accentColor: kFluggleSecondaryColor,
        brightness: Brightness.dark,
//        primaryColor: Colors.lightBlue[800],
//        accentColor: Colors.cyan[600],
        canvasColor: kFlugglePrimaryColor,
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: TextStyle(
                  //color: Color.fromRGBO(20, 51, 51, 1),
                  ),
              bodyText2: TextStyle(
                  //color: Color.fromRGBO(20, 51, 51, 1),
                  ),
              headline6: TextStyle(
                  //fontSize: 20,
                  //fontFamily: 'RobotoCondensed',
                  //fontWeight: FontWeight.bold,
                  //color: Color.fromRGBO(20, 51, 51, 1),
                  ),
            ),
      ),
      initialRoute: '/',
      routes: {
        HomeScreen.routeName: (ctx) => HomeScreen(),
        GameScreen.routeName: (ctx) => GameScreen(),
        ScoresScreen.routeName: (ctx) => ScoresScreen(),
      },
    );
  }
}
