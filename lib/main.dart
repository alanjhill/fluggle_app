import 'package:firebase_core/firebase_core.dart';
import 'package:fluggle_app/auth/auth_widget.dart';
import 'package:fluggle_app/widgets/app_theme.dart';
import 'package:fluggle_app/pages/home/home_page.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_page.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_view_model.dart';
import 'package:fluggle_app/routing/app_router.dart';
import 'package:fluggle_app/services/shared_preferences_service.dart';
import 'package:fluggle_app/top_level_providers.dart';
import 'package:fluggle_app/utils/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
    final firebaseAuth = context.read(firebaseAuthProvider);
    return MaterialApp(
      theme: appTheme.getThemeData(context),
      debugShowCheckedModeBanner: false,
      home: AuthWidget(
        nonSignedInBuilder: (_) => Consumer(
          builder: (context, watch, _) {
            final didCompleteOnboarding = watch(onboardingViewModelProvider);
            debugPrint('didCompleteOnboarding: $didCompleteOnboarding');
            return didCompleteOnboarding ? HomePage() : OnboardingPage();
            //return OnboardingPage();
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
  }
}
