import 'package:example/home/home.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

import '../../helpers/helpers.dart';

Future<void> pumpHome(WidgetTester tester) async {
  await tester.pumpApp(const HomePage());
}

Finder tabTrack() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is SizedBox && widget.width == 400 && widget.height == 64,
  );
}

Future<void> tapTab(WidgetTester tester, int index) async {
  final rect = tester.getRect(tabTrack());
  const inset = 4.0;
  const tabWidth = (400 - inset * 2) / 4;
  final x = rect.left + inset + index * tabWidth + tabWidth / 2;
  await tester.tapAt(Offset(x, rect.center.dy));
  await tester.pump();
}

void main() {
  group(HomePage, () {
    testWidgets('renders the jelly tab bar with configured items', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.byType(JellyTabBarHeadless), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.format_paint_outlined), findsOneWidget);
    });

    testWidgets('renders the badge on the camera tab', (tester) async {
      await pumpHome(tester);

      expect(find.text('3'), findsNWidgets(2));
    });

    testWidgets('shows the home body by default', (tester) async {
      await pumpHome(tester);

      expect(find.text('Home feed'), findsOneWidget);
    });

    testWidgets('switches the body when a tab is tapped', (tester) async {
      await pumpHome(tester);

      await tapTab(tester, 1);

      expect(find.text('Camera roll'), findsOneWidget);
    });

    testWidgets('switches the body back to the first tab', (tester) async {
      await pumpHome(tester);

      await tapTab(tester, 1);
      await tapTab(tester, 0);

      expect(find.text('Home feed'), findsOneWidget);
    });

    testWidgets('opens the customization showcase', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.byType(CustomizationPage), findsOneWidget);
    });
  });
}
