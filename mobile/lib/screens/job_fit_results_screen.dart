import 'package:flutter/material.dart';
import '../models/job_fit.dart';
import '../widgets/score_indicator.dart';
import '../widgets/section_card.dart';
import '../config/theme.dart';

class JobFitResultsScreen extends StatelessWidget {
  final JobFitResult result;

  const JobFitResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ScoreIndicator(score: result.matchScore),
            const SizedBox(height: 16),
            Text(
              result.summary,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (result.missingKeywords.isNotEmpty)
              SectionCard(
                title: 'Missing Keywords',
                icon: Icons.warning_amber_outlined,
                child: Column(
                  children: result.missingKeywords
                      .map((gap) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: gap.importance == 'high'
                                        ? AppTheme.errorColor.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    gap.importance.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: gap.importance == 'high'
                                          ? AppTheme.errorColor
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(gap.keyword),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            if (result.bulletSuggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              SectionCard(
                title: 'Suggested Improvements',
                icon: Icons.lightbulb_outline,
                child: Column(
                  children: result.bulletSuggestions
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Before:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(s.original,
                                    style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  'After:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                                Text(s.improved),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
