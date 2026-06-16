import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/landing_screen.dart';
import 'screens/home_screen.dart';
import 'screens/job_fit_screen.dart';
import 'screens/profile_boost_screen.dart';
import 'screens/cover_letter_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/feedback_screen.dart';

void main() {
  runApp(const JobPackApp());
}

class JobPackApp extends StatelessWidget {
  const JobPackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Pack',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
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
  }
}
