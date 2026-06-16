import '../models/job_fit.dart';
import '../models/profile_boost.dart';
import '../models/apply_letter.dart';

class MockService {
  Future<JobFitResult> analyzeJobFit({
    required String cvText,
    required String jobDescription,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return const JobFitResult(
      matchScore: 72,
      summary: 'Your CV matches 72% of the job requirements. Strong technical background, but missing some key skills.',
      missingKeywords: [
        KeywordGap(keyword: 'kubernetes', importance: 'high'),
        KeywordGap(keyword: 'ci/cd', importance: 'high'),
        KeywordGap(keyword: 'agile', importance: 'medium'),
      ],
      bulletSuggestions: [
        BulletSuggestion(
          original: 'Worked on backend services',
          improved: 'Architected and maintained scalable backend services handling 10K+ daily requests using Python and FastAPI',
        ),
        BulletSuggestion(
          original: 'Did code reviews',
          improved: 'Led code review processes across a team of 8 engineers, reducing production bugs by 30%',
        ),
      ],
    );
  }

  Future<ProfileBoostResult> generateProfileBoost({
    String headline = '',
    String about = '',
    String experience = '',
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return const ProfileBoostResult(
      improvedHeadline: 'Senior Software Engineer | Building Scalable Systems | Open Source Contributor',
      improvedAbout: 'I build reliable, scalable software that solves real problems. With 5+ years in backend development, I specialize in Python, cloud architecture, and mentoring engineering teams.\n\nI thrive in fast-paced environments where I can combine technical depth with product thinking to deliver meaningful impact.',
      improvedExperience: 'Senior Software Engineer at TechCo (2021–Present)\n\n• Designed and deployed microservices architecture serving 1M+ monthly users\n• Reduced API response times by 40% through query optimization and caching strategies\n• Mentored 4 junior engineers through structured 1-on-1 programs',
      tips: [
        'Add metrics and numbers to every bullet point',
        'Lead with your strongest differentiator in the headline',
        'Use the About section to tell your career story, not list skills',
      ],
    );
  }

  Future<ApplyLetterResult> generateCoverLetter({
    required String cvText,
    required String jobDescription,
    String tone = 'professional',
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return const ApplyLetterResult(
      coverLetter: 'Dear Hiring Manager,\n\nI am writing to express my strong interest in this position. With extensive experience in software development and a proven track record of delivering high-quality solutions, I am confident in my ability to contribute meaningfully to your team.\n\nThroughout my career, I have developed deep expertise in building scalable applications and collaborating with cross-functional teams. I am particularly drawn to this role because it aligns with my passion for solving complex technical challenges.\n\nI would welcome the opportunity to discuss how my background and skills can benefit your organization.\n\nBest regards',
    );
  }

  Future<bool> submitFeedback({
    required String category,
    required String title,
    required String description,
    String email = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
