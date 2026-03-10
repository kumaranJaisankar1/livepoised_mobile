class UserModel {
  final String sub;
  final String? username;
  final String? email;
  final String? givenName;
  final String? familyName;
  final String? name;
  final String? userType;

  UserModel({
    required this.sub,
    this.username,
    this.email,
    this.givenName,
    this.familyName,
    this.name,
    this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check for nested "user" object
    final userMap = (json.containsKey('user') && json['user'] is Map)
        ? json['user'] as Map<String, dynamic>
        : null;

    return UserModel(
      sub: json['sub'] ?? userMap?['sub'] ?? '',
      username: json['preferred_username'] ?? json['username'] ?? userMap?['username'],
      email: json['email'] ?? userMap?['email'],
      name: json['name'] ?? userMap?['name'],
      givenName: json['given_name'] ?? userMap?['given_name'],
      familyName: json['family_name'] ?? userMap?['family_name'],
      userType: json['user_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'preferred_username': username,
      'email': email,
      'given_name': givenName,
      'family_name': familyName,
      'name': name,
      'user_type': userType,
    };
  }
}
