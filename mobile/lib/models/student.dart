class Student {
  final String email;
  final int year;
  final int semester;
  final String? specialization;

  Student({
    required this.email,
    required this.year,
    required this.semester,
    this.specialization,
  });

  bool get hasSpecialization => specialization != null && specialization!.isNotEmpty;

  bool get needsSpecialization => year >= 2 && semester >= 3;

  Student copyWith({
    String? email,
    int? year,
    int? semester,
    String? specialization,
  }) {
    return Student(
      email: email ?? this.email,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      specialization: specialization ?? this.specialization,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'year': year,
      'semester': semester,
      'specialization': specialization,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      email: json['email'] as String,
      year: json['year'] as int,
      semester: json['semester'] as int,
      specialization: json['specialization'] as String?,
    );
  }

  static bool isValidEmail(String email) {
    return email.toLowerCase().endsWith('@alustudent.com');
  }
}
