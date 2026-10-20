class ProfileModel {
  final String id;
  final String fullName;
  final String role; // 'super_admin', 'finance_admin', 'field_staff', 'sales_staff'
  final bool isApproved;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.isApproved,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'field_staff',
      isApproved: json['is_approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'is_approved': isApproved,
    };
  }
}