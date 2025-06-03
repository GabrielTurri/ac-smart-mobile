class User {
  int ra;
  String id;
  String email;
  String role;
  String name;
  String surname;
  int totalApprovedHours;
  int totalPendingHours;
  int totalRejectedHours;
  Course course;

  User({
    required this.ra,
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.surname,
    required this.totalApprovedHours,
    required this.totalPendingHours,
    required this.totalRejectedHours,
    required this.course,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      ra: json['RA'],
      id: json['_id'],
      email: json['email'],
      role: json['role'],
      name: json['name'],
      surname: json['surname'],
      totalApprovedHours: json['total_approved_hours'],
      totalPendingHours: json['total_pending_hours'],
      totalRejectedHours: json['total_rejected_hours'],
      course: Course.fromJson(json['course']),
    );
  }
}

class Coordinator {
  String coordId;
  String coordEmail;
  String coordName;
  String coordSurname;
  List<Course>? courses;

  Coordinator({
    required this.coordId,
    required this.coordEmail,
    required this.coordName,
    required this.coordSurname,
    this.courses,
  });

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
      coordId: json['coordinator_id'],
      coordEmail: json['email'],
      coordName: json['name'],
      coordSurname: json['surname'],
      courses: json['courses'] != null
          ? (json['courses'] as List)
              .map((course) => Course.fromJson(course))
              .toList()
          : null,
    );
  }
}

class Course {
  String courseId;
  String courseName;
  int requiredHours;
  Coordinator coordinator;
  Course({
    required this.courseId,
    required this.courseName,
    required this.requiredHours,
    required this.coordinator,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'],
      courseName: json['name'],
      requiredHours: json['required_hours'],
      coordinator: Coordinator.fromJson(json['coordinator']),
    );
  }
}
