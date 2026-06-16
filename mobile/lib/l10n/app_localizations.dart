import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ro'),
  ];

  String get languageCode => locale.languageCode;

  String get(String key) => _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'ro': _ro,
  };

  // Common
  String get appName => get('appName');
  String get getStarted => get('getStarted');
  String get settings => get('settings');
  String get version => get('version');
  String get language => get('language');
  String get english => get('english');
  String get romanian => get('romanian');

  // Landing
  String get landingSubtitle => get('landingSubtitle');

  // Home
  String get whatToDo => get('whatToDo');
  String get jobFitAnalysis => get('jobFitAnalysis');
  String get jobFitDescription => get('jobFitDescription');
  String get profileBoost => get('profileBoost');
  String get profileBoostDescription => get('profileBoostDescription');
  String get coverLetter => get('coverLetter');
  String get coverLetterDescription => get('coverLetterDescription');
  String get coverLetters => get('coverLetters');
  String get sendFeedback => get('sendFeedback');

  // Job Fit
  String get jobFitInstructions => get('jobFitInstructions');
  String get cvResumeText => get('cvResumeText');
  String get cvHint => get('cvHint');
  String get jobDescription => get('jobDescription');
  String get jobDescriptionHint => get('jobDescriptionHint');
  String get analyzeMatch => get('analyzeMatch');
  String get analysisResults => get('analysisResults');
  String get missingKeywords => get('missingKeywords');
  String get suggestedImprovements => get('suggestedImprovements');
  String get before => get('before');
  String get after => get('after');
  String get match => get('match');
  String get minCharsError => get('minCharsError');

  // Profile Boost
  String get profileBoostInstructions => get('profileBoostInstructions');
  String get currentHeadline => get('currentHeadline');
  String get headlineHint => get('headlineHint');
  String get currentAbout => get('currentAbout');
  String get aboutHint => get('aboutHint');
  String get currentExperience => get('currentExperience');
  String get experienceHint => get('experienceHint');
  String get boostMyProfile => get('boostMyProfile');
  String get improvedHeadline => get('improvedHeadline');
  String get improvedAbout => get('improvedAbout');
  String get improvedExperience => get('improvedExperience');
  String get tips => get('tips');
  String get copy => get('copy');
  String get fillOneField => get('fillOneField');
  String get copiedToClipboard => get('copiedToClipboard');

  // Cover Letter
  String get coverLetterInstructions => get('coverLetterInstructions');
  String get tone => get('tone');
  String get toneProfessional => get('toneProfessional');
  String get toneCasual => get('toneCasual');
  String get toneEnthusiastic => get('toneEnthusiastic');
  String get generateLetter => get('generateLetter');
  String get yourCoverLetter => get('yourCoverLetter');
  String get coverLetterCopied => get('coverLetterCopied');

  // Settings
  String get appInfo => get('appInfo');
  String get mockServices => get('mockServices');
  String get enabled => get('enabled');
  String get disabled => get('disabled');
  String get backend => get('backend');
  String get baseUrl => get('baseUrl');
  String get connectionStatus => get('connectionStatus');
  String get connected => get('connected');
  String get notChecked => get('notChecked');
  String get test => get('test');
  String get backendReachable => get('backendReachable');
  String get backendNotReachable => get('backendNotReachable');
  String get support => get('support');

  // Feedback
  String get feedbackInstructions => get('feedbackInstructions');
  String get category => get('category');
  String get bug => get('bug');
  String get feature => get('feature');
  String get feedback => get('feedback');
  String get title => get('title');
  String get titleHint => get('titleHint');
  String get description => get('description');
  String get descriptionHint => get('descriptionHint');
  String get emailOptional => get('emailOptional');
  String get emailHint => get('emailHint');
  String get submitFeedback => get('submitFeedback');
  String get feedbackSubmitted => get('feedbackSubmitted');
  String get feedbackOffline => get('feedbackOffline');
  String get titleMinChars => get('titleMinChars');
  String get descriptionMinChars => get('descriptionMinChars');

  // Loading
  String get processing => get('processing');
  String get error => get('error');

  static const Map<String, String> _en = {
    'appName': 'Job Coach',
    'getStarted': 'Get Started',
    'settings': 'Settings',
    'version': 'Version',
    'language': 'Language',
    'english': 'English',
    'romanian': 'Română',

    'landingSubtitle': 'Your AI-powered job search toolkit.\nAnalyze fit, boost your profile, and generate cover letters.',

    'whatToDo': 'What would you like to do?',
    'jobFitAnalysis': 'Job Fit Analysis',
    'jobFitDescription': 'Paste your CV and a job description to see how well you match',
    'profileBoost': 'Profile Boost',
    'profileBoostDescription': 'Improve your LinkedIn headline, about, and experience sections',
    'coverLetter': 'Cover Letter',
    'coverLetterDescription': 'Generate a personalized cover letter for any job posting',
    'coverLetters': 'Cover Letters',
    'sendFeedback': 'Send Feedback',

    'jobFitInstructions': 'Paste your CV and the job description to see how well you match.',
    'cvResumeText': 'CV / Resume Text',
    'cvHint': 'Paste your CV content here...',
    'jobDescription': 'Job Description',
    'jobDescriptionHint': 'Paste the job posting here...',
    'analyzeMatch': 'Analyze Match',
    'analysisResults': 'Analysis Results',
    'missingKeywords': 'Missing Keywords',
    'suggestedImprovements': 'Suggested Improvements',
    'before': 'Before:',
    'after': 'After:',
    'match': 'Match',
    'minCharsError': 'Please enter at least 10 characters',

    'profileBoostInstructions': 'Paste your current LinkedIn sections to get AI-powered improvements.',
    'currentHeadline': 'Current Headline',
    'headlineHint': 'e.g. Software Engineer at TechCo',
    'currentAbout': 'Current About Section',
    'aboutHint': 'Paste your LinkedIn About section...',
    'currentExperience': 'Current Experience',
    'experienceHint': 'Paste your latest experience entry...',
    'boostMyProfile': 'Boost My Profile',
    'improvedHeadline': 'Improved Headline',
    'improvedAbout': 'Improved About',
    'improvedExperience': 'Improved Experience',
    'tips': 'Tips',
    'copy': 'Copy',
    'fillOneField': 'Please fill in at least one field',
    'copiedToClipboard': 'copied to clipboard',

    'coverLetterInstructions': 'Generate a personalized cover letter based on your CV and the job posting.',
    'tone': 'Tone',
    'toneProfessional': 'Professional',
    'toneCasual': 'Casual',
    'toneEnthusiastic': 'Enthusiastic',
    'generateLetter': 'Generate Letter',
    'yourCoverLetter': 'Your Cover Letter',
    'coverLetterCopied': 'Cover letter copied to clipboard',

    'appInfo': 'App Info',
    'mockServices': 'Mock Services',
    'enabled': 'Enabled',
    'disabled': 'Disabled',
    'backend': 'Backend',
    'baseUrl': 'Base URL',
    'connectionStatus': 'Connection Status',
    'connected': 'Connected',
    'notChecked': 'Not checked',
    'test': 'Test',
    'backendReachable': 'Backend is reachable',
    'backendNotReachable': 'Backend is not reachable',
    'support': 'Support',

    'feedbackInstructions': 'Help us improve Job Coach. Report bugs, request features, or share feedback.',
    'category': 'Category',
    'bug': 'Bug',
    'feature': 'Feature',
    'feedback': 'Feedback',
    'title': 'Title',
    'titleHint': 'Brief summary...',
    'description': 'Description',
    'descriptionHint': 'Describe the issue or suggestion in detail...',
    'emailOptional': 'Email (optional)',
    'emailHint': 'For follow-up if needed',
    'submitFeedback': 'Submit Feedback',
    'feedbackSubmitted': 'Thank you! Your feedback has been submitted.',
    'feedbackOffline': 'Feedback received (offline mode).',
    'titleMinChars': 'Title must be at least 3 characters',
    'descriptionMinChars': 'Please provide at least 10 characters',

    'processing': 'Processing...',
    'error': 'Error',
  };

  static const Map<String, String> _ro = {
    'appName': 'Job Coach',
    'getStarted': 'Începe',
    'settings': 'Setări',
    'version': 'Versiune',
    'language': 'Limbă',
    'english': 'English',
    'romanian': 'Română',

    'landingSubtitle': 'Asistentul tău AI pentru căutarea unui loc de muncă.\nAnalizează potrivirea, îmbunătățește profilul și generează scrisori de intenție.',

    'whatToDo': 'Ce dorești să faci?',
    'jobFitAnalysis': 'Analiză Potrivire',
    'jobFitDescription': 'Lipește CV-ul și descrierea jobului pentru a vedea cât de bine te potrivești',
    'profileBoost': 'Optimizare Profil',
    'profileBoostDescription': 'Îmbunătățește titlul, secțiunea Despre și experiența de pe LinkedIn',
    'coverLetter': 'Scrisoare de Intenție',
    'coverLetterDescription': 'Generează o scrisoare de intenție personalizată pentru orice job',
    'coverLetters': 'Scrisori de Intenție',
    'sendFeedback': 'Trimite Feedback',

    'jobFitInstructions': 'Lipește CV-ul și descrierea jobului pentru a vedea cât de bine te potrivești.',
    'cvResumeText': 'Text CV / Rezumat',
    'cvHint': 'Lipește conținutul CV-ului aici...',
    'jobDescription': 'Descrierea Jobului',
    'jobDescriptionHint': 'Lipește anunțul de job aici...',
    'analyzeMatch': 'Analizează Potrivirea',
    'analysisResults': 'Rezultate Analiză',
    'missingKeywords': 'Cuvinte Cheie Lipsă',
    'suggestedImprovements': 'Îmbunătățiri Sugerate',
    'before': 'Înainte:',
    'after': 'După:',
    'match': 'Potrivire',
    'minCharsError': 'Introduceți cel puțin 10 caractere',

    'profileBoostInstructions': 'Lipește secțiunile tale curente de pe LinkedIn pentru a primi îmbunătățiri.',
    'currentHeadline': 'Titlu Curent',
    'headlineHint': 'ex. Software Engineer la TechCo',
    'currentAbout': 'Secțiunea Despre Curentă',
    'aboutHint': 'Lipește secțiunea Despre de pe LinkedIn...',
    'currentExperience': 'Experiență Curentă',
    'experienceHint': 'Lipește ultima experiență profesională...',
    'boostMyProfile': 'Optimizează Profilul',
    'improvedHeadline': 'Titlu Îmbunătățit',
    'improvedAbout': 'Despre Îmbunătățit',
    'improvedExperience': 'Experiență Îmbunătățită',
    'tips': 'Sfaturi',
    'copy': 'Copiază',
    'fillOneField': 'Completează cel puțin un câmp',
    'copiedToClipboard': 'copiat în clipboard',

    'coverLetterInstructions': 'Generează o scrisoare de intenție personalizată pe baza CV-ului și a anunțului de job.',
    'tone': 'Ton',
    'toneProfessional': 'Profesional',
    'toneCasual': 'Casual',
    'toneEnthusiastic': 'Entuziast',
    'generateLetter': 'Generează Scrisoarea',
    'yourCoverLetter': 'Scrisoarea Ta de Intenție',
    'coverLetterCopied': 'Scrisoarea a fost copiată în clipboard',

    'appInfo': 'Informații Aplicație',
    'mockServices': 'Servicii Mock',
    'enabled': 'Activat',
    'disabled': 'Dezactivat',
    'backend': 'Backend',
    'baseUrl': 'URL Bază',
    'connectionStatus': 'Stare Conexiune',
    'connected': 'Conectat',
    'notChecked': 'Neverificat',
    'test': 'Testează',
    'backendReachable': 'Backend-ul este accesibil',
    'backendNotReachable': 'Backend-ul nu este accesibil',
    'support': 'Suport',

    'feedbackInstructions': 'Ajută-ne să îmbunătățim Job Coach. Raportează erori, solicită funcționalități sau trimite feedback.',
    'category': 'Categorie',
    'bug': 'Eroare',
    'feature': 'Funcționalitate',
    'feedback': 'Feedback',
    'title': 'Titlu',
    'titleHint': 'Rezumat scurt...',
    'description': 'Descriere',
    'descriptionHint': 'Descrie problema sau sugestia în detaliu...',
    'emailOptional': 'Email (opțional)',
    'emailHint': 'Pentru follow-up dacă este necesar',
    'submitFeedback': 'Trimite Feedback',
    'feedbackSubmitted': 'Mulțumim! Feedback-ul tău a fost trimis.',
    'feedbackOffline': 'Feedback primit (mod offline).',
    'titleMinChars': 'Titlul trebuie să aibă cel puțin 3 caractere',
    'descriptionMinChars': 'Introduceți cel puțin 10 caractere',

    'processing': 'Se procesează...',
    'error': 'Eroare',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.map((l) => l.languageCode).contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
