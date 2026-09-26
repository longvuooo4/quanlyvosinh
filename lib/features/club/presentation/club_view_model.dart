import 'package:flutter/foundation.dart';

import '../data/club_repository.dart';
import '../domain/club_snapshot.dart';

class ClubViewModel extends ChangeNotifier {
  ClubViewModel(this._repository);

  final ClubRepository _repository;
  ClubSnapshot _snapshot = ClubSnapshot.empty();
  String _query = '';
  bool loading = false;
  bool saving = false;
  String? error;
  bool _disposed = false;

  ClubSnapshot get snapshot => _snapshot;
  String get query => _query;
  List<KarateStudent> get students => _snapshot.students
      .where(
        (student) => '${student.name} ${student.id} ${student.phone}'
            .toLowerCase()
            .contains(_query.toLowerCase()),
      )
      .toList(growable: false);

  int get activeStudents => _snapshot.students
      .where((student) => student.status == StudentStatus.active)
      .length;
  int get income => _snapshot.finances
      .where((item) => item.type == FinanceType.income)
      .fold(0, (sum, item) => sum + item.amount);
  int get expense => _snapshot.finances
      .where((item) => item.type == FinanceType.expense)
      .fold(0, (sum, item) => sum + item.amount);
  int get balance => income - expense;

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      _snapshot = await _repository.load();
    } catch (_) {
      error = 'Không đọc được dữ liệu trên thiết bị. Vui lòng thử lại.';
    } finally {
      if (!_disposed) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void search(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Future<bool> renameClub(String value) =>
      _commit(_snapshot.copyWith(name: value.trim()));

  Future<bool> upsertStudent(KarateStudent student) {
    final students = [..._snapshot.students];
    final index = students.indexWhere((item) => item.id == student.id);
    if (index < 0) {
      students.add(student);
    } else {
      students[index] = student;
    }
    students.sort((a, b) => a.name.compareTo(b.name));
    return _commit(_snapshot.copyWith(students: students));
  }

  Future<bool> deleteStudent(String id) => _commit(
    _snapshot.copyWith(
      students: _snapshot.students.where((item) => item.id != id).toList(),
      attendance: _snapshot.attendance
          .map(
            (item) => AttendanceRecord(
              id: item.id,
              classId: item.classId,
              date: item.date,
              presentStudentIds: item.presentStudentIds
                  .where((studentId) => studentId != id)
                  .toList(),
            ),
          )
          .toList(),
    ),
  );

  Future<bool> upsertClass(KarateClass karateClass) {
    final classes = [..._snapshot.classes];
    final index = classes.indexWhere((item) => item.id == karateClass.id);
    if (index < 0) {
      classes.add(karateClass);
    } else {
      classes[index] = karateClass;
    }
    classes.sort((a, b) => a.name.compareTo(b.name));
    return _commit(_snapshot.copyWith(classes: classes));
  }

  Future<bool> deleteClass(String id) => _commit(
    _snapshot.copyWith(
      classes: _snapshot.classes.where((item) => item.id != id).toList(),
      students: _snapshot.students
          .map(
            (item) => item.copyWith(
              classIds: item.classIds
                  .where((classId) => classId != id)
                  .toList(),
            ),
          )
          .toList(),
      attendance: _snapshot.attendance
          .where((item) => item.classId != id)
          .toList(),
    ),
  );

  Future<bool> saveAttendance({
    required String classId,
    required DateTime date,
    required List<String> presentStudentIds,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final id = '$classId-${day.toIso8601String()}';
    final records = [..._snapshot.attendance];
    final record = AttendanceRecord(
      id: id,
      classId: classId,
      date: day,
      presentStudentIds: presentStudentIds,
    );
    final index = records.indexWhere((item) => item.id == id);
    if (index < 0) {
      records.add(record);
    } else {
      records[index] = record;
    }
    records.sort((a, b) => b.date.compareTo(a.date));
    return _commit(_snapshot.copyWith(attendance: records));
  }

  Future<bool> addFinance(FinanceRecord record) =>
      _commit(_snapshot.copyWith(finances: [record, ..._snapshot.finances]));

  Future<bool> deleteFinance(String id) => _commit(
    _snapshot.copyWith(
      finances: _snapshot.finances.where((item) => item.id != id).toList(),
    ),
  );

  Future<bool> _commit(ClubSnapshot next) async {
    final previous = _snapshot;
    _snapshot = next;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _repository.save(next);
      return true;
    } catch (_) {
      _snapshot = previous;
      error = 'Không lưu được thay đổi. Vui lòng thử lại.';
      return false;
    } finally {
      if (!_disposed) {
        saving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
