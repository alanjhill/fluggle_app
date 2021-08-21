import 'package:fluggle_app/widgets/word_cubes.dart';
import 'package:fluggle_app/custom_buttons/custom_buttons.dart';
import 'package:fluggle_app/pages/onboarding/onboarding_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WordCubes(word: 'FLUGGLE', width: MediaQuery.of(context).size.width - 32, spacing: 1.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'A BOGGLE like word game\nwritten using Flutter',
              style: TextStyle(),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            CustomRaisedButton(
              onPressed: () => onGetStarted(ref),
              child: Text(
                'Get Started',
                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onGetStarted(WidgetRef ref) async {
    final OnboardingViewModel onboardingViewModel = ref.read(onboardingViewModelProvider.notifier);
    await onboardingViewModel.completeOnboarding();
  }
}
