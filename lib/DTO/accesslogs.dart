class AccessLogs {
  final int userId;
  final int pageId;
  final String location;

  AccessLogs({
    required this.userId,
    required this.pageId,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pageId': pageId,
      'location': location,
    };
  }
}
