enum UserRole { admin, sales }

class User {
  final String id;
  final String name;
  final String email;
  final String? password;
  final UserRole role;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.sales,
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role == UserRole.admin ? 'admin' : 'sales',
      'profileImage': profileImage,
    };
  }
}
