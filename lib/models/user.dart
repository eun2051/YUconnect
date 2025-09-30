class User {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String department;
  final int grade;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.grade,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'grade': grade,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      department: map['department'] ?? '',
      grade: map['grade'] ?? 0,
    );
  }
}
