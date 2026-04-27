class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String tenantId;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? 'EMPLOYEE',
      tenantId: json['tenantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'tenantId': tenantId,
    };
  }
}
