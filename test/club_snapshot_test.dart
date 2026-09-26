import 'package:flutter_test/flutter_test.dart';
import 'package:quanlyvosinh/features/club/domain/club_snapshot.dart';

void main() {
  test('Snapshot survives JSON round trip', () {
    final original = ClubSnapshot(
      id: 'club',
      name: 'Karate Việt',
      students: [
        KarateStudent(id: 's1', name: 'An', joinedAt: DateTime(2026, 1, 2)),
      ],
      finances: [
        FinanceRecord(
          id: 'f1',
          type: FinanceType.expense,
          amount: 120000,
          category: 'Dụng cụ',
          date: DateTime(2026, 1, 3),
        ),
      ],
    );

    final restored = ClubSnapshot.fromJson(original.toJson());
    expect(restored.name, original.name);
    expect(restored.students.single.joinedAt, DateTime(2026, 1, 2));
    expect(restored.finances.single.type, FinanceType.expense);
    expect(restored.finances.single.amount, 120000);
  });
}
