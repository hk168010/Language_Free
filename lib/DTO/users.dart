class User {
  final String fullName;
  final String address;
  final String email;
  final String phone;
  final String gender;
  final DateTime dateOfBirth;
  final String national;

  User({
    required this.fullName,
    required this.address,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dateOfBirth,
    required this.national,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      fullName: json['fullName'] as String,
      address: json['address'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      national: json['national'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'national': national,
    };
  }
}
