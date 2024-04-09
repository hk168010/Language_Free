class UserView {
  final int userId;
  final String fullName;
  final String imageUser;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;
  final String national;

  UserView({
    required this.userId,
    required this.fullName,
    required this.imageUser,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.national,
  });

  factory UserView.fromJson(Map<String, dynamic> json) {
    return UserView(
      userId: json['userId'],
      fullName: json['fullName'],
      imageUser: json['imageUser'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      national: json['national'],
    );
  }
}