import 'package:flutter/semantics.dart';
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

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
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

    testWidgets('applies colors overrides', (tester) async {
      await pumpBar(
        tester,
        const JellyTabBarHeadless(
          items: _items,
          colors: JellyTabsColorsOverride(
            surface: Color(0xFF123456),
            selectedSurface: Color(0xFF654321),
          ),
        ),
      );

      final surface = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF123456),
      );
      expect(surface, findsOneWidget);
      final selectedSurface = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF654321),
      );
      expect(selectedSurface, findsOneWidget);
    });

    testWidgets('applies opacity overrides', (tester) async {
      await pumpBar(
        tester,
        const JellyTabBarHeadless(
          items: _items,
          opacity: JellyTabsOpacityOverride(surface: 0.5),
        ),
      );

      final surface = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox &&
            widget.color == const Color(0xFF22211F).withValues(alpha: 0.5),
      );
      expect(surface, findsOneWidget);
    });

    testWidgets('re-resolves colors when they change after build', (
      tester,
    ) async {
      await tester.pumpAppWidget(
        const JellyTabBarHeadless(
          items: _items,
          colors: JellyTabsColorsOverride(surface: Color(0xFF111111)),
        ),
      );
      await tester.pump();
      await tester.pumpAppWidget(
        const JellyTabBarHeadless(
          items: _items,
          colors: JellyTabsColorsOverride(surface: Color(0xFF222222)),
        ),
      );
      await tester.pump();

      final surface = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == const Color(0xFF222222),
      );
      expect(surface, findsOneWidget);
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

    group('gestures', () {
      testWidgets('tap selects the tab and fires onTabPress and onTabChange', (
        tester,
      ) async {
        final pressEvents = <JellyTabsChangeEvent>[];
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(
            items: _items,
            onTabPress: (event) {
              pressEvents.add(event);
              return true;
            },
            onTabChange: changeEvents.add,
          ),
        );

        await tester.tap(find.byType(JellyTabBarHeadless));
        await settle(tester);

        expect(pressEvents, hasLength(1));
        expect(pressEvents.single.index, 1);
        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
      });

      testWidgets('drag across tabs selects the nearest tab on release', (
        tester,
      ) async {
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabChange: changeEvents.add),
        );

        final gesture = await tester.startGesture(const Offset(250, 300));
        await tester.pump();
        await gesture.moveTo(const Offset(550, 300));
        await tester.pump();
        await gesture.up();
        await settle(tester);

        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
      });

      testWidgets('long-press fires onTabLongPress for the held tab', (
        tester,
      ) async {
        final longPresses = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabLongPress: longPresses.add),
        );

        final gesture = await tester.startGesture(const Offset(400, 300));
        await tester.pump(const Duration(milliseconds: 600));
        await gesture.up();
        await settle(tester);

        expect(longPresses, hasLength(1));
        expect(longPresses.single.index, 1);
      });

      testWidgets('rejected press restores the prior selection', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(
            items: _items,
            onTabPress: (_) => false,
            onTabChange: changeEvents.add,
          ),
        );

        await tester.tap(find.byType(JellyTabBarHeadless));
        await settle(tester);

        expect(changeEvents, isEmpty);
        final homeTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Home'),
        );
        expect(homeTab.properties.selected, isTrue);
        final searchTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Search'),
        );
        expect(searchTab.properties.selected, isFalse);
        handle.dispose();
      });
    });

    group('controlled selection', () {
      testWidgets('animates the pill when selectedIndex changes externally', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpAppWidget(
          const JellyTabBarHeadless(items: _items, selectedIndex: 0),
        );
        await tester.pump();

        await tester.pumpAppWidget(
          const JellyTabBarHeadless(items: _items, selectedIndex: 1),
        );
        await settle(tester);

        final searchTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Search'),
        );
        expect(searchTab.properties.selected, isTrue);
        final homeTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Home'),
        );
        expect(homeTab.properties.selected, isFalse);
        handle.dispose();
      });
    });

    group('semantics', () {
      testWidgets('exposes tab role, selected state, and tap actions', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpBar(tester, const JellyTabBarHeadless(items: _items));

        final homeTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Home'),
        );
        expect(homeTab.properties.role, SemanticsRole.tab);
        expect(homeTab.properties.selected, isTrue);
        expect(homeTab.properties.onTap, isNotNull);
        expect(homeTab.properties.onLongPress, isNull);

        final searchTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Search'),
        );
        expect(searchTab.properties.selected, isFalse);
        expect(searchTab.properties.onTap, isNotNull);
        handle.dispose();
      });

      testWidgets('adds a long-press action when onTabLongPress is set', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabLongPress: (_) {}),
        );

        final homeTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Home'),
        );
        expect(homeTab.properties.onLongPress, isNotNull);
        handle.dispose();
      });

      testWidgets('activate action selects the tab', (tester) async {
        final handle = tester.ensureSemantics();
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabChange: changeEvents.add),
        );

        final searchTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Search'),
        );
        searchTab.properties.onTap!.call();
        await settle(tester);

        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
        handle.dispose();
      });
    });
  });
}
