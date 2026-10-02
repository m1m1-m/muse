import 'package:flutter_test/flutter_test.dart';
import 'package:muse_frontend/main.dart';

void main() {
  testWidgets('MUSE app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MuseApp());

    expect(find.text('MUSE'), findsOneWidget);
    expect(find.text('Firebase Connected'), findsOneWidget);
  });
}