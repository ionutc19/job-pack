class ApplyLetterResult {
  final String coverLetter;

  const ApplyLetterResult({required this.coverLetter});

  factory ApplyLetterResult.fromJson(Map<String, dynamic> json) {
    return ApplyLetterResult(
      coverLetter: json['cover_letter'] as String,
    );
  }
}
