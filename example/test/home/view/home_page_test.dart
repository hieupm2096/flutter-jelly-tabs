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

Future<void> expandPanel(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  group(HomePage, () {
    testWidgets('renders the jelly tab bar with configured items', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.byType(JellyTabBarHeadless), findsOneWidget);
      expect(find.byIcon(Icons.home), findsWidgets);
      expect(find.byIcon(Icons.photo_camera), findsWidgets);
      expect(find.byIcon(Icons.settings), findsWidgets);
      expect(find.byIcon(Icons.format_paint), findsWidgets);
    });

    testWidgets('renders the customizer header', (tester) async {
      await pumpHome(tester);

      expect(find.text('flutter-jelly-tabs'), findsOneWidget);
      expect(find.text('Change bg'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('switches selection when a tab is tapped', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpHome(tester);

      await tapTab(tester, 1);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      final cameraTab = tester.widget<Semantics>(
        find.bySemanticsLabel('Camera'),
      );
      expect(cameraTab.properties.selected, isTrue);
      final homeTab = tester.widget<Semantics>(
        find.bySemanticsLabel('Home'),
      );
      expect(homeTab.properties.selected, isFalse);
      handle.dispose();
    });

    testWidgets('applies a palette to the tab bar', (tester) async {
      await pumpHome(tester);
      await expandPanel(tester, 'Palette');

      await tester.tap(find.byKey(const Key('palette-Blue')));
      await tester.pumpAndSettle();

      final bar = tester.widget<JellyTabBarHeadless>(
        find.byType(JellyTabBarHeadless),
      );
      expect(bar.colors?.selectedSurface, const Color(0xFF2563EB));
      expect(bar.colors?.surface, const Color(0xFF18181B));
    });

    testWidgets('reset restores the default amber look', (tester) async {
      await pumpHome(tester);
      await expandPanel(tester, 'Palette');
      await tester.tap(find.byKey(const Key('palette-Blue')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      final bar = tester.widget<JellyTabBarHeadless>(
        find.byType(JellyTabBarHeadless),
      );
      expect(bar.colors?.selectedSurface, const Color(0xFFF59E0B));
      expect(bar.colors?.surface, const Color(0xFF1C1917));
    });

    testWidgets('shuffles the background when requested', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Change bg'));
      await tester.pump();
    });

    testWidgets('scrolls the customizer when a panel is expanded', (
      tester,
    ) async {
      await pumpHome(tester);
      await expandPanel(tester, 'Palette');

      final scrollable = find
          .descendant(
            of: find.byType(SingleChildScrollView).first,
            matching: find.byType(Scrollable),
          )
          .first;
      final positionBefore = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(positionBefore, 0);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      final positionAfter = tester
          .state<ScrollableState>(scrollable)
          .position
          .pixels;
      expect(positionAfter, greaterThan(positionBefore));
    });
  });
}
