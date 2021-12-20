import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluggle_app/auth/auth_widget.dart';
import 'package:fluggle_app/pages/landing/landing_page.dart';
import 'package:fluggle_app/pages/sign_in/sign_in_page.dart';
import 'package:fluggle_app/services/friends/friends_service.dart';
import 'package:fluggle_app/services/game/game_service.dart';
import 'package:fluggle_app/services/user/user_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:fluggle_app/widgets/app_theme.dart';
import 'package:fluggle_app/pages/home/home_page.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_page.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_view_model.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/shared_preferences_service.dart';
import 'package:fluggle_app/utils/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, LogicalKeyboardKey;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Use Emulator?
  const useEmulator = String.fromEnvironment("USE_EMULATOR");
  if (useEmulator == 'true') {
    // [Firestore | localhost:8080]
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );

    // [Authentication | localhost:9099]
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    // [Storage | localhost:9199]
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  Language.registerLoader(
    LanguageLoader(
      words: (code) => rootBundle.loadString('assets/dictionary/$code.dic'),
    ),
  );

  // Create the services
  final sharedPreferences = await SharedPreferences.getInstance();
  final gameService = GameService();
  final friendsService = FriendsService();
  final userService = UserService();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
      friendsServiceProvider.overrideWithValue(friendsService),
      gameServiceProvider.overrideWithValue(gameService),
      userServiceProvider.overrideWithValue(userService),
    ],
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  final AppTheme appTheme = AppTheme();

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseAuth = ref.read(firebaseAuthProvider);
/*    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kFluggleCanvasColor,
      statusBarIconBrightness: Brightness.light,
    ));*/
    // TODO: This doesn't work
    final shortcuts = Map.of(WidgetsApp.defaultShortcuts)..remove(LogicalKeySet(LogicalKeyboardKey.escape));
    return MaterialApp(
      shortcuts: shortcuts,
      theme: appTheme.getThemeData(context),
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => const LandingPage(),
        signedInBuilder: (_) => const HomePage(),
      ),
      onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
        context,
        settings,
        firebaseAuth,
      ),
    );
  }
}
