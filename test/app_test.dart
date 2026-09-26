import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanlyvosinh/app/app.dart';
import 'package:quanlyvosinh/features/club/data/club_repository.dart';

void main() {
  testWidgets('App opens official empty state and navigates', (tester) async {
    await tester.pumpWidget(KarateApp(repository: MemoryClubRepository()));
    await tester.pumpAndSettle();

    expect(find.text('CLB Karate của tôi'), findsOneWidget);
    expect(find.textContaining('BẢN MẪU'), findsNothing);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có võ sinh'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có lớp tập'), findsOneWidget);
  });

  testWidgets('Small screen and large text remain usable', (tester) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(KarateApp(repository: MemoryClubRepository()));
    await tester.pumpAndSettle();
    for (final icon in [
      Icons.people_outline,
      Icons.calendar_month_outlined,
      Icons.fact_check_outlined,
    ]) {
      await tester.tap(find.byIcon(icon));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
