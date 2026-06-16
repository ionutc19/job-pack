class ProfileBoostResult {
  final String improvedHeadline;
  final String improvedAbout;
  final String improvedExperience;
  final List<String> tips;

  const ProfileBoostResult({
    required this.improvedHeadline,
    required this.improvedAbout,
    required this.improvedExperience,
    required this.tips,
  });

  factory ProfileBoostResult.fromJson(Map<String, dynamic> json) {
    return ProfileBoostResult(
      improvedHeadline: json['improved_headline'] as String,
      improvedAbout: json['improved_about'] as String,
      improvedExperience: json['improved_experience'] as String,
      tips: (json['tips'] as List).cast<String>(),
    );
  }
}
