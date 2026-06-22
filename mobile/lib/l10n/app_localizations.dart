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
  String get account => get('account');
  String get userId => get('userId');

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

  // Plans
  String get plans => get('plans');
  String get choosePlan => get('choosePlan');
  String get plansSubtitle => get('plansSubtitle');
  String get currentPlan => get('currentPlan');
  String get planFree => get('planFree');
  String get planFreePrice => get('planFreePrice');
  String get planFreeAds => get('planFreeAds');
  String get planFreeRequests => get('planFreeRequests');
  String get planFreeModules => get('planFreeModules');
  String get planPremium => get('planPremium');
  String get planPremiumPrice => get('planPremiumPrice');
  String get planPremiumNoAds => get('planPremiumNoAds');
  String get planPremiumRequests => get('planPremiumRequests');
  String get planPremiumModules => get('planPremiumModules');
  String get planPro => get('planPro');
  String get planProPrice => get('planProPrice');
  String get planProNoAds => get('planProNoAds');
  String get planProRequests => get('planProRequests');
  String get planProModules => get('planProModules');
  String get planProFairUse => get('planProFairUse');
  String upgradeTo(String plan) => get('upgradeTo').replaceAll('{plan}', plan);
  String get planUpgradeCta => get('planUpgradeCta');
  String get restorePurchases => get('restorePurchases');
  String get restoringPurchases => get('restoringPurchases');
  String get billingUnavailable => get('billingUnavailable');

  // File upload
  String get uploadCv => get('uploadCv');
  String get uploadJd => get('uploadJd');
  String get extractingText => get('extractingText');
  String get removeFile => get('removeFile');
  String get replaceFile => get('replaceFile');
  String get fileTooLarge => get('fileTooLarge');
  String get fileConsentTitle => get('fileConsentTitle');
  String get fileConsentPicker => get('fileConsentPicker');
  String get fileConsentSelected => get('fileConsentSelected');
  String get fileConsentTemporary => get('fileConsentTemporary');
  String get fileConsentNoStorage => get('fileConsentNoStorage');
  String get fileConsentContinue => get('fileConsentContinue');
  String get fileUploadError => get('fileUploadError');

  // Legal
  String get termsOfService => get('termsOfService');
  String get viewOnline => get('viewOnline');

  // Privacy
  String get privacyTitle => get('privacyTitle');
  String get privacyDataProcessing => get('privacyDataProcessing');
  String get privacyDataProcessingBody => get('privacyDataProcessingBody');
  String get privacyAiUsage => get('privacyAiUsage');
  String get privacyAiUsageBody => get('privacyAiUsageBody');
  String get privacyDataStorage => get('privacyDataStorage');
  String get privacyDataStorageBody => get('privacyDataStorageBody');
  String get privacySubscriptions => get('privacySubscriptions');
  String get privacySubscriptionsBody => get('privacySubscriptionsBody');
  String get privacyThirdParty => get('privacyThirdParty');
  String get privacyThirdPartyBody => get('privacyThirdPartyBody');
  String get privacyContact => get('privacyContact');
  String get privacyContactBody => get('privacyContactBody');
  String get privacyLastUpdated => get('privacyLastUpdated');

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
    'account': 'Account',
    'userId': 'User ID',

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

    // Plans
    'plans': 'Plans',
    'choosePlan': 'Choose Your Plan',
    'plansSubtitle': 'Select the plan that fits your job search needs.',
    'currentPlan': 'Current',
    'planFree': 'Free',
    'planFreePrice': '\$0 / month',
    'planFreeAds': 'Ads supported',
    'planFreeRequests': '5 requests per month per module',
    'planFreeModules': 'All 3 modules included',
    'planPremium': 'Premium',
    'planPremiumPrice': '\$3.99 / month',
    'planPremiumNoAds': 'No ads',
    'planPremiumRequests': '20 requests per day per module',
    'planPremiumModules': 'All 3 modules included',
    'planPro': 'Pro',
    'planProPrice': '\$9.99 / month',
    'planProNoAds': 'No ads',
    'planProRequests': 'Unlimited access',
    'planProModules': 'All 3 modules included',
    'planProFairUse': 'Fair use policy applies',
    'upgradeTo': 'Upgrade to {plan}',
    'planUpgradeCta': 'Upgrade for more daily analyses',
    'restorePurchases': 'Restore Purchases',
    'restoringPurchases': 'Restoring...',
    'billingUnavailable': 'In-app purchases are not available on this device',

    // File upload
    'uploadCv': 'Upload',
    'uploadJd': 'Upload',
    'extractingText': 'Extracting...',
    'removeFile': 'Remove',
    'replaceFile': 'Replace',
    'fileTooLarge': 'File exceeds 10 MB limit',
    'fileConsentTitle': 'Upload a Document',
    'fileConsentPicker': 'Your device\'s file picker will open so you can choose a file.',
    'fileConsentSelected': 'Only the file you select will be accessed.',
    'fileConsentTemporary': 'File content is processed temporarily for this request only.',
    'fileConsentNoStorage': 'Your file is not stored — it is discarded after processing.',
    'fileConsentContinue': 'Choose File',
    'fileUploadError': 'Could not extract text from this file.',

    // Legal
    'termsOfService': 'Terms of Service',
    'viewOnline': 'View online',

    // Privacy
    'privacyTitle': 'Privacy & Legal',
    'privacyDataProcessing': 'Data Processing',
    'privacyDataProcessingBody': 'When you use Job Coach, your input (CV text, job descriptions, LinkedIn profile sections) is sent to our backend server for processing. This data is transmitted securely and used solely to generate your requested analysis, profile improvements, or cover letter.',
    'privacyAiUsage': 'AI-Powered Results',
    'privacyAiUsageBody': 'Job Coach uses artificial intelligence models hosted on Microsoft Azure to generate results. Your input is forwarded to the AI model as part of the request. The AI processes your data in real time and does not retain it after generating a response.',
    'privacyDataStorage': 'Data Storage',
    'privacyDataStorageBody': 'Job Coach does not permanently store your CV text, job descriptions, or generated results on our servers. Input data is processed in memory and discarded after the response is delivered. Your language preference and a stable app user ID are stored locally on your device. Usage counters, subscription status, and entitlement data are stored on the server to enforce plan limits.',
    'privacySubscriptions': 'Subscriptions & Entitlements',
    'privacySubscriptionsBody': 'If you subscribe to a paid plan, your subscription status and usage data (request counts, tier information) may be processed and stored to enforce plan limits. Payment processing is handled by third-party billing providers.',
    'privacyThirdParty': 'Third-Party Services & Advertising',
    'privacyThirdPartyBody': 'In the future, the free tier may include advertisements served by third-party ad networks. These services may collect device identifiers and usage data according to their own privacy policies. We will update this section when advertising is enabled.',
    'privacyContact': 'Contact',
    'privacyContactBody': 'If you have questions about how your data is handled, please use the Send Feedback feature in the app or contact us through the app settings.',
    'privacyLastUpdated': 'Last updated: June 2026',
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
    'account': 'Cont',
    'userId': 'ID Utilizator',

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

    // Plans
    'plans': 'Planuri',
    'choosePlan': 'Alege Planul Tău',
    'plansSubtitle': 'Selectează planul potrivit pentru căutarea ta de job.',
    'currentPlan': 'Curent',
    'planFree': 'Gratuit',
    'planFreePrice': '\$0 / lună',
    'planFreeAds': 'Cu reclame',
    'planFreeRequests': '5 cereri pe lună per modul',
    'planFreeModules': 'Toate cele 3 module incluse',
    'planPremium': 'Premium',
    'planPremiumPrice': '\$3,99 / lună',
    'planPremiumNoAds': 'Fără reclame',
    'planPremiumRequests': '20 cereri pe zi per modul',
    'planPremiumModules': 'Toate cele 3 module incluse',
    'planPro': 'Pro',
    'planProPrice': '\$9,99 / lună',
    'planProNoAds': 'Fără reclame',
    'planProRequests': 'Acces nelimitat',
    'planProModules': 'Toate cele 3 module incluse',
    'planProFairUse': 'Se aplică politica de utilizare corectă',
    'upgradeTo': 'Treci la {plan}',
    'planUpgradeCta': 'Upgradează pentru mai multe analize zilnice',
    'restorePurchases': 'Restaurează Achizițiile',
    'restoringPurchases': 'Se restaurează...',
    'billingUnavailable': 'Achizițiile din aplicație nu sunt disponibile pe acest dispozitiv',

    // File upload
    'uploadCv': 'Încarcă',
    'uploadJd': 'Încarcă',
    'extractingText': 'Se extrage...',
    'removeFile': 'Elimină',
    'replaceFile': 'Înlocuiește',
    'fileTooLarge': 'Fișierul depășește limita de 10 MB',
    'fileConsentTitle': 'Încarcă un Document',
    'fileConsentPicker': 'Se va deschide selectorul de fișiere al dispozitivului tău.',
    'fileConsentSelected': 'Doar fișierul pe care îl selectezi va fi accesat.',
    'fileConsentTemporary': 'Conținutul fișierului este procesat temporar, doar pentru această cerere.',
    'fileConsentNoStorage': 'Fișierul tău nu este stocat — este eliminat după procesare.',
    'fileConsentContinue': 'Alege Fișierul',
    'fileUploadError': 'Nu s-a putut extrage textul din acest fișier.',

    // Privacy
    // Legal
    'termsOfService': 'Termeni și Condiții',
    'viewOnline': 'Vezi online',

    'privacyTitle': 'Confidențialitate și Legal',
    'privacyDataProcessing': 'Procesarea Datelor',
    'privacyDataProcessingBody': 'Când folosești Job Coach, datele introduse (text CV, descrieri de job, secțiuni de profil LinkedIn) sunt trimise către serverul nostru pentru procesare. Aceste date sunt transmise securizat și utilizate exclusiv pentru a genera analiza, îmbunătățirile de profil sau scrisoarea de intenție solicitată.',
    'privacyAiUsage': 'Rezultate Generate de AI',
    'privacyAiUsageBody': 'Job Coach folosește modele de inteligență artificială găzduite pe Microsoft Azure pentru a genera rezultate. Datele introduse sunt transmise modelului AI ca parte a cererii. AI-ul procesează datele în timp real și nu le reține după generarea răspunsului.',
    'privacyDataStorage': 'Stocarea Datelor',
    'privacyDataStorageBody': 'Job Coach nu stochează permanent textul CV-ului, descrierile de job sau rezultatele generate pe serverele noastre. Datele introduse sunt procesate în memorie și eliminate după livrarea răspunsului. Preferința de limbă și un ID stabil de utilizator sunt stocate local pe dispozitivul tău. Contoarele de utilizare, statusul abonamentului și datele de drepturi sunt stocate pe server pentru aplicarea limitelor planului.',
    'privacySubscriptions': 'Abonamente și Drepturi',
    'privacySubscriptionsBody': 'Dacă te abonezi la un plan plătit, statusul abonamentului și datele de utilizare (număr de cereri, informații despre plan) pot fi procesate și stocate pentru aplicarea limitelor planului. Procesarea plăților este gestionată de furnizori terți de facturare.',
    'privacyThirdParty': 'Servicii Terțe și Publicitate',
    'privacyThirdPartyBody': 'În viitor, planul gratuit poate include reclame difuzate de rețele publicitare terțe. Aceste servicii pot colecta identificatori de dispozitiv și date de utilizare conform propriilor politici de confidențialitate. Vom actualiza această secțiune când publicitatea va fi activată.',
    'privacyContact': 'Contact',
    'privacyContactBody': 'Dacă ai întrebări despre modul în care sunt gestionate datele tale, te rugăm să folosești funcția Trimite Feedback din aplicație sau să ne contactezi prin setările aplicației.',
    'privacyLastUpdated': 'Ultima actualizare: iunie 2026',
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
