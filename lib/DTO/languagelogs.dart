class LanguageLogs {
  final int userId;
  final int pageId;
  final String languageTarget;
  final String location;

  final bool fromOrTo;

  LanguageLogs({
    required this.userId,
    required this.pageId,
    required this.languageTarget,
    required this.location,
    required this.fromOrTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pageId': pageId,
      'languageTarget': languageTarget,
      'location': location,
      'fromOrTo': fromOrTo,
    };
  }
}
