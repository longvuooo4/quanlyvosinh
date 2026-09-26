enum StudentStatus { active, paused }

class KarateStudent {
  const KarateStudent({
    required this.id,
    required this.name,
    this.phone = '',
    this.belt = 'Đai trắng',
    this.status = StudentStatus.active,
    this.classIds = const [],
    required this.joinedAt,
  });

  final String id;
  final String name;
  final String phone;
  final String belt;
  final StudentStatus status;
  final List<String> classIds;
  final DateTime joinedAt;

  KarateStudent copyWith({
    String? name,
    String? phone,
    String? belt,
    StudentStatus? status,
    List<String>? classIds,
  }) => KarateStudent(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    belt: belt ?? this.belt,
    status: status ?? this.status,
    classIds: classIds ?? this.classIds,
    joinedAt: joinedAt,
  );

  factory KarateStudent.fromJson(Map<String, dynamic> json) => KarateStudent(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String? ?? '',
    belt: json['belt'] as String? ?? 'Đai trắng',
    status: StudentStatus.values.byName(
      json['status'] as String? ?? StudentStatus.active.name,
    ),
    classIds: List<String>.from(json['classIds'] as List? ?? const []),
    joinedAt: DateTime.parse(json['joinedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'belt': belt,
    'status': status.name,
    'classIds': classIds,
    'joinedAt': joinedAt.toIso8601String(),
  };
}

class KarateClass {
  const KarateClass({
    required this.id,
    required this.name,
    required this.schedule,
    this.coach = '',
    this.location = '',
  });

  final String id;
  final String name;
  final String schedule;
  final String coach;
  final String location;

  KarateClass copyWith({
    String? name,
    String? schedule,
    String? coach,
    String? location,
  }) => KarateClass(
    id: id,
    name: name ?? this.name,
    schedule: schedule ?? this.schedule,
    coach: coach ?? this.coach,
    location: location ?? this.location,
  );

  factory KarateClass.fromJson(Map<String, dynamic> json) => KarateClass(
    id: json['id'] as String,
    name: json['name'] as String,
    schedule: json['schedule'] as String,
    coach: json['coach'] as String? ?? '',
    location: json['location'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'schedule': schedule,
    'coach': coach,
    'location': location,
  };
}

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.classId,
    required this.date,
    required this.presentStudentIds,
  });

  final String id;
  final String classId;
  final DateTime date;
  final List<String> presentStudentIds;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String,
        classId: json['classId'] as String,
        date: DateTime.parse(json['date'] as String),
        presentStudentIds: List<String>.from(
          json['presentStudentIds'] as List? ?? const [],
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'date': date.toIso8601String(),
    'presentStudentIds': presentStudentIds,
  };
}

enum FinanceType { income, expense }

class FinanceRecord {
  const FinanceRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    this.note = '',
    required this.date,
  });

  final String id;
  final FinanceType type;
  final int amount;
  final String category;
  final String note;
  final DateTime date;

  factory FinanceRecord.fromJson(Map<String, dynamic> json) => FinanceRecord(
    id: json['id'] as String,
    type: FinanceType.values.byName(json['type'] as String),
    amount: json['amount'] as int,
    category: json['category'] as String,
    note: json['note'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'category': category,
    'note': note,
    'date': date.toIso8601String(),
  };
}

class ClubSnapshot {
  const ClubSnapshot({
    required this.id,
    required this.name,
    this.students = const [],
    this.classes = const [],
    this.attendance = const [],
    this.finances = const [],
  });

  final String id;
  final String name;
  final List<KarateStudent> students;
  final List<KarateClass> classes;
  final List<AttendanceRecord> attendance;
  final List<FinanceRecord> finances;

  ClubSnapshot copyWith({
    String? name,
    List<KarateStudent>? students,
    List<KarateClass>? classes,
    List<AttendanceRecord>? attendance,
    List<FinanceRecord>? finances,
  }) => ClubSnapshot(
    id: id,
    name: name ?? this.name,
    students: students ?? this.students,
    classes: classes ?? this.classes,
    attendance: attendance ?? this.attendance,
    finances: finances ?? this.finances,
  );

  factory ClubSnapshot.empty() =>
      const ClubSnapshot(id: 'local-club', name: 'CLB Karate của tôi');

  factory ClubSnapshot.fromJson(Map<String, dynamic> json) => ClubSnapshot(
    id: json['id'] as String? ?? 'local-club',
    name: json['name'] as String? ?? 'CLB Karate của tôi',
    students: (json['students'] as List? ?? const [])
        .map((e) => KarateStudent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    classes: (json['classes'] as List? ?? const [])
        .map((e) => KarateClass.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    attendance: (json['attendance'] as List? ?? const [])
        .map(
          (e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    finances: (json['finances'] as List? ?? const [])
        .map((e) => FinanceRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'students': students.map((e) => e.toJson()).toList(),
    'classes': classes.map((e) => e.toJson()).toList(),
    'attendance': attendance.map((e) => e.toJson()).toList(),
    'finances': finances.map((e) => e.toJson()).toList(),
  };
}
