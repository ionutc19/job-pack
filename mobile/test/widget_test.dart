import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_pack/main.dart';

void main() {
  testWidgets('Landing screen shows app name and get started button', (tester) async {
    await tester.pumpWidget(const JobPackApp());

    expect(find.text('Job Pack'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Job Fit Analysis'), findsOneWidget);
    expect(find.text('Profile Boost'), findsOneWidget);
    expect(find.text('Cover Letters'), findsOneWidget);
  });

  testWidgets('Tapping Get Started navigates to home screen', (tester) async {
    await tester.pumpWidget(const JobPackApp());

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('What would you like to do?'), findsOneWidget);
    expect(find.text('Job Fit Analysis'), findsOneWidget);
    expect(find.text('Profile Boost'), findsOneWidget);
    expect(find.text('Cover Letter'), findsOneWidget);
  });

  testWidgets('Home screen navigates to job fit screen', (tester) async {
    await tester.pumpWidget(const JobPackApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Job Fit Analysis'));
    await tester.pumpAndSettle();

    expect(find.text('Job Fit Analysis'), findsOneWidget);
    expect(find.text('Analyze Match'), findsOneWidget);
  });

  testWidgets('Home screen navigates to feedback screen', (tester) async {
    await tester.pumpWidget(const JobPackApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send Feedback'));
    await tester.pumpAndSettle();

    expect(find.text('Send Feedback'), findsWidgets);
    expect(find.text('Submit Feedback'), findsOneWidget);
  });

  testWidgets('Home screen navigates to settings screen', (tester) async {
    await tester.pumpWidget(const JobPackApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
  });
}
