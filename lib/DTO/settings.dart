class Setting {
  final int userId;
  final String uiLanguagePreference;
  final String translationLanguageFrom;
  final String translationLanguageTo;
  final String conversationLanguageFrom;
  final String conversationLanguageTo;
  final String pictureLangTo;

  Setting({
    required this.userId,
    required this.uiLanguagePreference,
    required this.translationLanguageFrom,
    required this.translationLanguageTo,
    required this.conversationLanguageFrom,
    required this.conversationLanguageTo,
    required this.pictureLangTo,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      userId: json['userId'] ?? 0,
      uiLanguagePreference: json['uiLanguagePreference'] ?? '',
      translationLanguageFrom: json['translationLanguageFrom'] ?? '',
      translationLanguageTo: json['translationLanguageTo'] ?? '',
      conversationLanguageFrom: json['conversationLanguageFrom'] ?? '',
      conversationLanguageTo: json['conversationLanguageTo'] ?? '',
      pictureLangTo: json['pictureLangTo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'uiLanguagePreference': uiLanguagePreference,
      'translationLanguageFrom': translationLanguageFrom,
      'translationLanguageTo': translationLanguageTo,
      'conversationLanguageFrom': conversationLanguageFrom,
      'conversationLanguageTo': conversationLanguageTo,
      'pictureLangTo': pictureLangTo,
    };
  }
}
