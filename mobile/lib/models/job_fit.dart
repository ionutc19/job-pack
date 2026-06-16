class KeywordGap {
  final String keyword;
  final String importance;

  const KeywordGap({required this.keyword, required this.importance});

  factory KeywordGap.fromJson(Map<String, dynamic> json) {
    return KeywordGap(
      keyword: json['keyword'] as String,
      importance: json['importance'] as String,
    );
  }
}

class BulletSuggestion {
  final String original;
  final String improved;

  const BulletSuggestion({required this.original, required this.improved});

  factory BulletSuggestion.fromJson(Map<String, dynamic> json) {
    return BulletSuggestion(
      original: json['original'] as String,
      improved: json['improved'] as String,
    );
  }
}

class JobFitResult {
  final int matchScore;
  final String summary;
  final List<KeywordGap> missingKeywords;
  final List<BulletSuggestion> bulletSuggestions;

  const JobFitResult({
    required this.matchScore,
    required this.summary,
    required this.missingKeywords,
    required this.bulletSuggestions,
  });

  factory JobFitResult.fromJson(Map<String, dynamic> json) {
    return JobFitResult(
      matchScore: json['match_score'] as int,
      summary: json['summary'] as String,
      missingKeywords: (json['missing_keywords'] as List)
          .map((e) => KeywordGap.fromJson(e as Map<String, dynamic>))
          .toList(),
      bulletSuggestions: (json['bullet_suggestions'] as List)
          .map((e) => BulletSuggestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
