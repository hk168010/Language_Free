class Account {
  final String username;
  final String password;
  Account({
    required this.username,
    required this.password,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
