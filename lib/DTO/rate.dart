class Rate {
  final int userId;
  final int rateNum;
  final String location;

  Rate({
    required this.userId,
    required this.rateNum,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'rateNum': rateNum,
      'location': location,
    };
  }
}
