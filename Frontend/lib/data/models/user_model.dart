class User {
  final String userId;
  final String username;
  final String token;
  final String role; // <--- هل هذا الحقل موجود؟

  User({
    required this.userId,
    required this.username,
    required this.token,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'].toString(),
      username: json['username'] ?? 'User',
      token: json['token'],
      // السطر الحاسم: هل يقرأ التطبيق الدور من الـ JSON؟
      role: json['role'] ?? 'Student',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'token': token,
      'role': role,
    };
  }
}