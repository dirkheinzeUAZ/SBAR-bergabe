// Basic smoke test for the SBAR Übergabe app.
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:sbar_uebergabe/main.dart';
import 'package:sbar_uebergabe/services/storage_service.dart';

void main() {
  testWidgets('App startet und zeigt Bettenliste', (WidgetTester tester) async {
    Hive.init('./.hive_test');
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(SbarUebergabeApp(storageService: storageService));
    await tester.pumpAndSettle();

    expect(find.text('SBAR Übergabe'), findsOneWidget);
  });
}
