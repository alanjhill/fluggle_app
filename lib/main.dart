import 'package:firebase_core/firebase_core.dart';
import 'package:fluggle_app/auth/auth_widget.dart';
import 'package:fluggle_app/auth/auth_widget_builder.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/models/game/game.dart';
import 'package:fluggle_app/models/user/fluggle_user.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:fluggle_app/screens/home/home_screen.dart';
import 'package:fluggle_app/screens/play_game/play_game_screen.dart';
import 'package:fluggle_app/screens/previous_games/previous_games_screen.dart';
import 'package:fluggle_app/screens/scores/scores_screen.dart';
import 'package:fluggle_app/screens/sign_in/sign_in_page.dart';
import 'package:fluggle_app/screens/start_game/start_game_screen.dart';
import 'package:fluggle_app/services/auth/auth_service.dart';
import 'package:fluggle_app/services/auth/auth_service_adapter.dart';
import 'package:fluggle_app/services/auth/firebase_auth_service.dart';
import 'package:fluggle_app/services/database/firestore_database.dart';
import 'package:fluggle_app/widgets/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MyApp(
      authServiceBuilder: (_) => FirebaseAuthService(),
      databaseBuilder: (_, uid) => FirestoreDatabase(
        uid: uid,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.authServiceBuilder,
    required this.databaseBuilder,
    this.initialAuthServiceType = AuthServiceType.firebase,
  }) : super(key: key);
  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirebaseAuthService Function(BuildContext context) authServiceBuilder;
  final FirestoreDatabase Function(BuildContext context, String uid) databaseBuilder;
  final AuthServiceType initialAuthServiceType;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    // MultiProvider for top-level services that don't depend on any runtime values (e.g. uid)
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: widget.authServiceBuilder,
        ),
        Provider<AuthService>(
          create: (_) => AuthServiceAdapter(initialAuthServiceType: widget.initialAuthServiceType),
          dispose: (_, AuthService authService) => authService.dispose(),
        ),
      ],
      child: AuthWidgetBuilder(
        databaseBuilder: widget.databaseBuilder,
        builder: (BuildContext context, AsyncSnapshot<FluggleUser?> userSnapshot) {
          return MaterialApp(
              theme: ThemeData(
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
              ),
              debugShowCheckedModeBanner: false,
              home: AuthWidget(userSnapshot: userSnapshot),
              //initialRoute: HomeScreen.routeName,
              routes: {
                //HomeScreenBuilder.routeName: (ctx) => HomeScreenBuilder(),
                //GameScreen.routeName: (ctx) => GameScreen(),
                //ScoresScreen.routeName: (ctx) => ScoresScreen(),
                //FriendsScreen.routeName: (ctx) => FriendsScreen(),
                //PlayGameScreen.routeName: (ctx) => PlayGameScreen(),
                //StartGameScreen.routeName: (ctx) => StartGameScreen(),
                //PreviousGamesScreen.routeName: (ctx) => PreviousGamesScreen(),
                //SignInPageBuilder.routeName: (ctx) => SignInPageBuilder(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == HomeScreenBuilder.routeName) {
                  return pageTransition(context, page: HomeScreenBuilder());
                } else if (settings.name == GameScreen.routeName) {
                  final Game game = settings.arguments as Game;
                  return pageTransition(context, page: GameScreen(game: game));
                } else if (settings.name == FriendsScreen.routeName) {
                  return pageTransition(context, page: FriendsScreen());
                } else if (settings.name == PlayGameScreen.routeName) {
                  return pageTransition(context, page: PlayGameScreen());
                } else if (settings.name == StartGameScreen.routeName) {
                  final StartGameArguments startGameArguments = settings.arguments as StartGameArguments;
                  return pageTransition(context, page: StartGameScreen(startGameArguments: startGameArguments));
                } else if (settings.name == ScoresScreen.routeName) {
                  final Game game = settings.arguments as Game;
                  return pageTransition(context, page: ScoresScreen(game: game));
                } else if (settings.name == PreviousGamesScreen.routeName) {
                  return pageTransition(context, page: PreviousGamesScreen());
                } else if (settings.name == SignInPageBuilder.routeName) {
                  return pageTransition(context, page: SignInPageBuilder());
                }
              });
        },
      ),
    );
  }
}

/*


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = const Settings(host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => MyApp(),
    ),
  );
}

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
        FriendsScreen.routeName: (ctx) => FriendsScreen(),
        NewGameScreen.routeName: (ctx) => NewGameScreen(),
        PreviousGamesScreen.routeName: (ctx) => PreviousGamesScreen(),
        LoginScreen.routeName: (ctx) => LoginScreen(),
      },
    );
  }
}
*/
