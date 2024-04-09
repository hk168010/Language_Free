class TranslationData {
  int translationId;
  int userId;
  int pageId;
  String sourceLanguage;
  String targetLanguage;
  String sourceText;
  String translatedText;
  String location;
  String status;

  TranslationData({
    required this.translationId,
    required this.userId,
    required this.pageId,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.sourceText,
    required this.translatedText,
    required this.location,
    required this.status
  });

  factory TranslationData.fromJson(Map<String, dynamic> json) {
    return TranslationData(
      translationId: json['translationId'] ?? 0,
      userId: json['userId'] ?? 0,
      pageId: json['pageId'] ?? 0,
      sourceLanguage: json['sourceLanguage'] ?? '',
      targetLanguage: json['targetLanguage'] ?? '',
      sourceText: json['sourceText'] ?? '',
      translatedText: json['translatedText'] ?? '',
      location: json['location'] ?? '',
      status: json['status']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'pageId': pageId,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'location': location,
    };
    return data;
  }
}
