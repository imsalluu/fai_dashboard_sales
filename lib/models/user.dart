enum UserRole { admin, sales }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;
  final String? assignedProfile; // e.g., "AI Hook", "Drift AI"

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.assignedProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.sales,
      profileImage: json['profileImage'],
      assignedProfile: json['assignedProfile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'sales',
      'profileImage': profileImage,
      'assignedProfile': assignedProfile,
    };
  }
}
