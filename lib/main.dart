import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluggle_app/auth/auth_widget.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:fluggle_app/widgets/app_theme.dart';
import 'package:fluggle_app/pages/home/home_page.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_page.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_view_model.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/shared_preferences_service.dart';
import 'package:fluggle_app/utils/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const bool USE_EMULATOR = true;

  if (USE_EMULATOR) {
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

  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        SharedPreferencesService(sharedPreferences),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final AppTheme appTheme = AppTheme();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      return MaterialApp(
        theme: appTheme.getThemeData(context),
        debugShowCheckedModeBanner: false,
        home: AuthWidget(
          nonSignedInBuilder: (_) => Consumer(
            builder: (context, ref, _) {
              final didCompleteOnboarding = ref.watch(onboardingViewModelProvider);
              debugPrint('didCompleteOnboarding: $didCompleteOnboarding');
              return didCompleteOnboarding ? HomePage() : OnboardingPage();
            },
          ),
          signedInBuilder: (_) => HomePage(),
        ),
        onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
          context,
          settings,
          firebaseAuth,
        ),
      );
    });
  }
}
