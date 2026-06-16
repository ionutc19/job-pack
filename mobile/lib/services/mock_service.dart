import '../models/job_fit.dart';
import '../models/profile_boost.dart';
import '../models/apply_letter.dart';

class MockService {
  Future<JobFitResult> analyzeJobFit({
    required String cvText,
    required String jobDescription,
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final isRo = language == 'ro';
    return JobFitResult(
      matchScore: 72,
      summary: isRo
          ? 'CV-ul tău se potrivește în proporție de 72% cu cerințele jobului. Pregătire tehnică solidă, dar lipsesc câteva competențe cheie.'
          : 'Your CV matches 72% of the job requirements. Strong technical background, but missing some key skills.',
      missingKeywords: [
        KeywordGap(keyword: 'kubernetes', importance: isRo ? 'ridicat' : 'high'),
        KeywordGap(keyword: 'ci/cd', importance: isRo ? 'ridicat' : 'high'),
        KeywordGap(keyword: 'agile', importance: isRo ? 'mediu' : 'medium'),
      ],
      bulletSuggestions: [
        BulletSuggestion(
          original: isRo ? 'Am lucrat pe servicii backend' : 'Worked on backend services',
          improved: isRo
              ? 'Am arhitecturat și întreținut servicii backend scalabile care procesează peste 10.000 de cereri zilnice folosind Python și FastAPI'
              : 'Architected and maintained scalable backend services handling 10K+ daily requests using Python and FastAPI',
        ),
        BulletSuggestion(
          original: isRo ? 'Am făcut review de cod' : 'Did code reviews',
          improved: isRo
              ? 'Am condus procesele de review de cod într-o echipă de 8 ingineri, reducând erorile de producție cu 30%'
              : 'Led code review processes across a team of 8 engineers, reducing production bugs by 30%',
        ),
      ],
    );
  }

  Future<ProfileBoostResult> generateProfileBoost({
    String headline = '',
    String about = '',
    String experience = '',
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final isRo = language == 'ro';
    return ProfileBoostResult(
      improvedHeadline: isRo
          ? 'Senior Software Engineer | Construiesc Sisteme Scalabile | Contributor Open Source'
          : 'Senior Software Engineer | Building Scalable Systems | Open Source Contributor',
      improvedAbout: isRo
          ? 'Construiesc software fiabil și scalabil care rezolvă probleme reale. Cu peste 5 ani de experiență în dezvoltare backend, mă specializez în Python, arhitectură cloud și mentorarea echipelor de ingineri.\n\nExcelez în medii dinamice unde pot combina profunzimea tehnică cu gândirea orientată spre produs.'
          : 'I build reliable, scalable software that solves real problems. With 5+ years in backend development, I specialize in Python, cloud architecture, and mentoring engineering teams.\n\nI thrive in fast-paced environments where I can combine technical depth with product thinking to deliver meaningful impact.',
      improvedExperience: isRo
          ? 'Senior Software Engineer la TechCo (2021–Prezent)\n\n• Am proiectat și implementat arhitectură de microservicii pentru peste 1M utilizatori lunari\n• Am redus timpii de răspuns API cu 40% prin optimizarea query-urilor și strategii de caching\n• Am mentorat 4 ingineri juniori prin programe structurate 1-la-1'
          : 'Senior Software Engineer at TechCo (2021–Present)\n\n• Designed and deployed microservices architecture serving 1M+ monthly users\n• Reduced API response times by 40% through query optimization and caching strategies\n• Mentored 4 junior engineers through structured 1-on-1 programs',
      tips: isRo
          ? [
              'Adaugă metrici și cifre la fiecare bullet point',
              'Pune în evidență principalul tău diferențiator în titlu',
              'Folosește secțiunea Despre pentru a spune povestea carierei, nu pentru a lista competențe',
            ]
          : [
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
    String language = 'en',
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    final isRo = language == 'ro';
    return ApplyLetterResult(
      coverLetter: isRo
          ? 'Stimate Angajator,\n\nVă scriu pentru a-mi exprima interesul puternic pentru această poziție. Cu experiență solidă în dezvoltarea software și un parcurs dovedit de livrare a soluțiilor de calitate, sunt încrezător în capacitatea mea de a contribui semnificativ echipei dumneavoastră.\n\nDe-a lungul carierei mele, am dezvoltat expertiză în construirea de aplicații scalabile și colaborarea cu echipe cross-funcționale. Sunt atras în mod deosebit de acest rol pentru că se aliniază cu pasiunea mea pentru rezolvarea provocărilor tehnice complexe.\n\nAș aprecia oportunitatea de a discuta cum experiența și abilitățile mele pot aduce valoare organizației dumneavoastră.\n\nCu respect'
          : 'Dear Hiring Manager,\n\nI am writing to express my strong interest in this position. With extensive experience in software development and a proven track record of delivering high-quality solutions, I am confident in my ability to contribute meaningfully to your team.\n\nThroughout my career, I have developed deep expertise in building scalable applications and collaborating with cross-functional teams. I am particularly drawn to this role because it aligns with my passion for solving complex technical challenges.\n\nI would welcome the opportunity to discuss how my background and skills can benefit your organization.\n\nBest regards',
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
