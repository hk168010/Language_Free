class UserVoice {
  final String gender;
  final DateTime dateOfBirth;

  UserVoice({required this.gender, required this.dateOfBirth});

  factory UserVoice.fromJson(Map<String, dynamic> json) {
    String gender = json['gender'] ?? 'Female';
    DateTime dob = json['dateOfBirth'] != null
        ? DateTime.tryParse(json['dateOfBirth']) ?? DateTime(2000, 3, 25, 17, 0, 0)
        : DateTime(2000, 3, 25, 17, 0, 0);

    return UserVoice(
      gender: gender,
      dateOfBirth: dob,
    );
  }
}
