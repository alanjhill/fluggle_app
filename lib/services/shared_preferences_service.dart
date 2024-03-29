import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((ref) => throw UnimplementedError());

class SharedPreferencesService {
  SharedPreferencesService(this.sharedPreferences);
  final SharedPreferences sharedPreferences;

  static const onboardingCompleteKey = 'onboardingComplete';

  Future<void> setOnboardingComplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, true);
  }

  Future<void> setOnboardingIncomplete() async {
    await sharedPreferences.setBool(onboardingCompleteKey, false);
  }

  Future<void> clear() async {
    await sharedPreferences.clear();
  }

  bool isOnboardingComplete() => sharedPreferences.getBool(onboardingCompleteKey) ?? false;
}
