import 'package:flutter_test/flutter_test.dart';
import 'package:nebula_v1/main.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Nebula'), findsOneWidget);
  });
}
