import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'l10n/app_localizations.dart';
import 'l10n/language_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';
import 'screens/job_fit_screen.dart';
import 'screens/profile_boost_screen.dart';
import 'screens/cover_letter_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/plans_screen.dart';
import 'screens/privacy_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageProvider = LanguageProvider();
  await languageProvider.load();
  runApp(JobCoachApp(languageProvider: languageProvider));
}

class JobCoachApp extends StatelessWidget {
  final LanguageProvider languageProvider;

  const JobCoachApp({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: languageProvider,
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) {
          return MaterialApp(
            title: 'Job Coach',
            theme: AppTheme.light,
            debugShowCheckedModeBanner: false,
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
              '/plans': (_) => const PlansScreen(),
              '/privacy': (_) => const PrivacyScreen(),
            },
          );
        },
      ),
    );
  }
}
