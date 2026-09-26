import 'package:flutter_test/flutter_test.dart';
import 'package:quanlyvosinh/features/club/data/club_repository.dart';
import 'package:quanlyvosinh/features/club/domain/club_snapshot.dart';
import 'package:quanlyvosinh/features/club/presentation/club_view_model.dart';

void main() {
  test('CRUD data is committed to the repository', () async {
    final repository = MemoryClubRepository();
    final model = ClubViewModel(repository);
    addTearDown(model.dispose);
    await model.load();

    const karateClass = KarateClass(
      id: 'class-1',
      name: 'Karate thiếu nhi',
      schedule: 'Thứ 2, 4, 6',
    );
    final student = KarateStudent(
      id: 'student-1',
      name: 'Nguyễn Minh Anh',
      classIds: const ['class-1'],
      joinedAt: DateTime(2026, 9, 26),
    );
    await model.upsertClass(karateClass);
    await model.upsertStudent(student);
    await model.saveAttendance(
      classId: karateClass.id,
      date: DateTime(2026, 9, 26),
      presentStudentIds: [student.id],
    );
    await model.addFinance(
      FinanceRecord(
        id: 'finance-1',
        type: FinanceType.income,
        amount: 500000,
        category: 'Học phí',
        date: DateTime(2026, 9, 26),
      ),
    );

    expect(repository.snapshot.students.single.name, 'Nguyễn Minh Anh');
    expect(repository.snapshot.classes.single.name, 'Karate thiếu nhi');
    expect(repository.snapshot.attendance.single.presentStudentIds, [
      'student-1',
    ]);
    expect(model.balance, 500000);
  });

  test('Deleting a class clears enrollment and attendance', () async {
    final initial = ClubSnapshot(
      id: 'club',
      name: 'CLB',
      classes: const [KarateClass(id: 'c1', name: 'Lớp 1', schedule: 'T2')],
      students: [
        KarateStudent(
          id: 's1',
          name: 'Võ sinh',
          classIds: const ['c1'],
          joinedAt: DateTime(2026),
        ),
      ],
      attendance: [
        AttendanceRecord(
          id: 'a1',
          classId: 'c1',
          date: DateTime(2026),
          presentStudentIds: const ['s1'],
        ),
      ],
    );
    final model = ClubViewModel(MemoryClubRepository(initial));
    addTearDown(model.dispose);
    await model.load();
    await model.deleteClass('c1');

    expect(model.snapshot.classes, isEmpty);
    expect(model.snapshot.students.single.classIds, isEmpty);
    expect(model.snapshot.attendance, isEmpty);
  });
}
