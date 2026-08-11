import 'package:example/app/app.dart';
import 'package:example/home/home.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders the home page', (tester) async {
      await tester.pumpWidget(const App());

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
