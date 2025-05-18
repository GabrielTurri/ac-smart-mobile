// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  int ra;
  String id;
  String email;
  String role;
  String name;
  String surname;
  int totalApprovedHours;
  int totalPendingdHours;
  int totalRejectedHours;

  Map<Coordinator, dynamic> coordinator;
  Map<Course, dynamic> course;

  User({
    required this.ra,
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.surname,
    required this.totalApprovedHours,
    required this.totalPendingdHours,
    required this.totalRejectedHours,
    required this.coordinator,
    required this.course,
  });
}

class Coordinator {
  String coordId;
  String coordEmail;
  String coordName;
  String coordSurname;
  List<Course> courses;

  Coordinator({
    required this.coordId,
    required this.coordEmail,
    required this.coordName,
    required this.coordSurname,
    required this.courses,
  });
}

class Course {
  String courseId;
  String courseName;
  int requiredHours;
  Course({
    required this.courseId,
    required this.courseName,
    required this.requiredHours,
  });
}
