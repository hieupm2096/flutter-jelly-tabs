import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

import '../../helpers/pump_app.dart';

Widget _homeActive(JellyTabsIconProps props) =>
    Icon(Icons.home_filled, color: props.color, size: props.size);

Widget _homeInactive(JellyTabsIconProps props) =>
    Icon(Icons.home, color: props.color, size: props.size);

Widget _searchActive(JellyTabsIconProps props) =>
    Icon(Icons.search, color: props.color, size: props.size);

Widget _searchInactive(JellyTabsIconProps props) =>
    Icon(Icons.search_off, color: props.color, size: props.size);

const _items = [
  JellyTabsItem(
    key: 'home',
    label: 'Home',
    activeIcon: _homeActive,
    inactiveIcon: _homeInactive,
  ),
  JellyTabsItem(
    key: 'search',
    label: 'Search',
    activeIcon: _searchActive,
    inactiveIcon: _searchInactive,
  ),
];

const _badgedItems = [
  JellyTabsItem(
    key: 'home',
    label: 'Home',
    badge: 5,
    activeIcon: _homeActive,
    inactiveIcon: _homeInactive,
  ),
  JellyTabsItem(
    key: 'search',
    label: 'Search',
    activeIcon: _searchActive,
    inactiveIcon: _searchInactive,
  ),
];

Future<void> pumpBar(WidgetTester tester, Widget bar) async {
  await tester.pumpAppWidget(bar);
  await tester.pump();
}

void main() {
  group(JellyTabBarHeadless, () {
    testWidgets('renders the track with the surface color and opacity', (
      tester,
    ) async {
      await pumpBar(tester, const JellyTabBarHeadless(items: _items));

      final surface = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF22211F),
      );
      expect(surface, findsOneWidget);
    });

    testWidgets('renders inactive icons and the active row in the pill', (
      tester,
    ) async {
      await pumpBar(tester, const JellyTabBarHeadless(items: _items));

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_filled), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets(
      'renders the pill and selected surface when a tab is selected',
      (
        tester,
      ) async {
        await pumpBar(tester, const JellyTabBarHeadless(items: _items));

        expect(find.byType(ClipPath), findsOneWidget);
        final selectedSurface = find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox && widget.color == const Color(0xFFF2EEE7),
        );
        expect(selectedSurface, findsOneWidget);
      },
    );

    testWidgets('renders no pill when items is empty', (tester) async {
      await pumpBar(tester, const JellyTabBarHeadless(items: []));

      expect(find.byType(ClipPath), findsNothing);
    });

    testWidgets('hides the pill for a negative controlled selection', (
      tester,
    ) async {
      await pumpBar(
        tester,
        const JellyTabBarHeadless(items: _items, selectedIndex: -1),
      );

      expect(find.byType(ClipPath), findsNothing);
    });

    testWidgets('renders badges on inactive and active tab copies', (
      tester,
    ) async {
      await pumpBar(tester, const JellyTabBarHeadless(items: _badgedItems));

      expect(find.text('5'), findsNWidgets(2));
    });

    testWidgets('caps the bar at maxWidth and centers it', (tester) async {
      await pumpBar(tester, const JellyTabBarHeadless(items: _items));

      final track = find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 400 && widget.height == 64,
      );
      expect(tester.getSize(track), const Size(400, 64));
      expect(tester.getTopLeft(track).dx, closeTo(200, 1e-3));
    });
  });
}
