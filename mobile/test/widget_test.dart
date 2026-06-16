import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:job_coach/l10n/app_localizations.dart';
import 'package:job_coach/l10n/language_provider.dart';
import 'package:job_coach/config/theme.dart';
import 'package:job_coach/screens/landing_screen.dart';
import 'package:job_coach/screens/home_screen.dart';
import 'package:job_coach/screens/job_fit_screen.dart';
import 'package:job_coach/screens/profile_boost_screen.dart';
import 'package:job_coach/screens/cover_letter_screen.dart';
import 'package:job_coach/screens/settings_screen.dart';
import 'package:job_coach/screens/feedback_screen.dart';

Widget buildTestApp() {
  final langProvider = LanguageProvider();
  return ChangeNotifierProvider.value(
    value: langProvider,
    child: Consumer<LanguageProvider>(
      builder: (context, lang, _) {
        return MaterialApp(
          theme: AppTheme.light,
          locale: lang.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (_) => const LandingScreen(),
            '/home': (_) => const HomeScreen(),
            '/job-fit': (_) => const JobFitScreen(),
            '/profile-boost': (_) => const ProfileBoostScreen(),
            '/cover-letter': (_) => const CoverLetterScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/feedback': (_) => const FeedbackScreen(),
          },
        );
      },
    ),
  );
}

void main() {
  testWidgets('Landing screen shows app name and get started button', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Job Coach'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Tapping Get Started navigates to home screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('What would you like to do?'), findsOneWidget);
  });

  testWidgets('Home screen navigates to job fit screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Job Fit Analysis'));
    await tester.pumpAndSettle();

    expect(find.text('Analyze Match'), findsOneWidget);
  });

  testWidgets('Home screen navigates to settings screen', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
  });
}
