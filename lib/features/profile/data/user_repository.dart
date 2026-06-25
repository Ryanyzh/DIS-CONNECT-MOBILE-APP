import '../../../core/network/api_client.dart';

class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  // Scholar fields
  final String? studentId;
  final String? faculty;
  final String? program;
  final int? yearOfStudy;
  final String? scholarshipType;
  // HR fields
  final String? employeeId;
  final String? designation;
  final String? departmentId;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.studentId,
    this.faculty,
    this.program,
    this.yearOfStudy,
    this.scholarshipType,
    this.employeeId,
    this.designation,
    this.departmentId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? '',
      studentId: json['student_id'] as String?,
      faculty: json['faculty'] as String?,
      program: json['program'] as String?,
      yearOfStudy: json['year_of_study'] as int?,
      scholarshipType: json['scholarship_type'] as String?,
      employeeId: json['employee_id'] as String?,
      designation: json['designation'] as String?,
      departmentId: json['department_id'] as String?,
    );
  }
}

class UserRepository {
  final ApiClient apiClient;
  UserRepository(this.apiClient);

  Future<UserProfile> getUserById(String userId) async {
    final json = await apiClient.get('/api/v1/users/$userId') as Map<String, dynamic>;
    return UserProfile.fromJson(json);
  }
}
