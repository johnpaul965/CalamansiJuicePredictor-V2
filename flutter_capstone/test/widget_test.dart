import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calamansi_yield_capstone/main.dart';

void main() {
  testWidgets('CalamansiYieldApp boots cleanly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CalamansiYieldApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Calamansi'), findsWidgets);
  });
}
