import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluggle_app/auth/application_state.dart';
import 'package:fluggle_app/auth_widget.dart';
import 'package:fluggle_app/auth_widget_builder.dart';
import 'package:fluggle_app/constants.dart';
import 'package:fluggle_app/screens/friends/friends_screen.dart';
import 'package:fluggle_app/screens/game/game_screen.dart';
import 'package:fluggle_app/screens/home_screen.dart';
import 'package:fluggle_app/screens/login_screen.dart';
import 'package:fluggle_app/screens/new_game_screen.dart';
import 'package:fluggle_app/screens/previous_games_screen.dart';
import 'package:fluggle_app/screens/scores_screen.dart';
import 'package:fluggle_app/services/auth_service.dart';
import 'package:fluggle_app/services/auth_service_adapter.dart';
import 'package:fluggle_app/services/email_secure_store.dart';
import 'package:fluggle_app/services/firebase_auth_service.dart';
import 'package:fluggle_app/services/firebase_email_link_handler.dart';
import 'package:fluggle_app/services/firestore_database.dart';
import 'package:fluggle_app/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp(
    authServiceBuilder: (_) => FirebaseAuthService(),
    databaseBuilder: (_, uid) => FirestoreDatabase(uid: uid),
  ));
}

class MyApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // MultiProvider for top-level services that don't depend on any runtime values (e.g. uid)
    return MultiProvider(
      providers: [
        Provider<FirebaseAuthService>(
          create: authServiceBuilder,
        ),
        Provider<AuthService>(
            create: (_) => AuthServiceAdapter(initialAuthServiceType: initialAuthServiceType), dispose: (_, AuthService authService) => authService.dispose()),
        Provider<EmailSecureStore>(
          create: (_) => EmailSecureStore(
            flutterSecureStorage: FlutterSecureStorage(),
          ),
        ),
        ProxyProvider2<AuthService, EmailSecureStore, FirebaseEmailLinkHandler>(
          update: (_, AuthService authService, EmailSecureStore storage, __) => FirebaseEmailLinkHandler(
            auth: authService,
            emailStore: storage,
            firebaseDynamicLinks: FirebaseDynamicLinks.instance,
          )..init(),
          dispose: (_, linkHandler) => linkHandler.dispose(),
        ),
      ],
      child: AuthWidgetBuilder(
        databaseBuilder: databaseBuilder,
        builder: (BuildContext context, AsyncSnapshot<FluggleAppUser?> userSnapshot) {
          return MaterialApp(
            theme: ThemeData(primarySwatch: Colors.indigo),
            debugShowCheckedModeBanner: false,
            home: AuthWidget(userSnapshot: userSnapshot),
            initialRoute: HomeScreen.routeName,
            routes: {
              HomeScreen.routeName: (ctx) => HomeScreen(),
              GameScreen.routeName: (ctx) => GameScreen(),
              ScoresScreen.routeName: (ctx) => ScoresScreen(),
              FriendsScreen.routeName: (ctx) => FriendsScreen(),
              NewGameScreen.routeName: (ctx) => NewGameScreen(),
              PreviousGamesScreen.routeName: (ctx) => PreviousGamesScreen(),
              SignInPageBuilder.routeName: (ctx) => SignInPageBuilder(),
            },
          );
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
