class Comment {
  final int userId;
  final int pageId;
  final String commentText;
  final String location;

  Comment({
    required this.userId,
    required this.pageId,
    required this.commentText,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pageId': pageId,
      'commentText': commentText,
      'location': location,
    };
  }
}
