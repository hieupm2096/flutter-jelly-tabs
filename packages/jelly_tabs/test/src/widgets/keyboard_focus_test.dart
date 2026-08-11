import 'package:flutter/services.dart';
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

Future<void> pumpBar(WidgetTester tester, Widget bar) async {
  await tester.pumpAppWidget(bar);
  await tester.pump();
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

/// The [FocusNode] backing the tab whose semantics label is [label].
FocusNode focusOfTab(WidgetTester tester, String label) {
  return Focus.of(tester.element(find.bySemanticsLabel(label)));
}

void main() {
  group(JellyTabBarHeadless, () {
    group('keyboard & focus', () {
      testWidgets('tabs are focusable and tab traversal follows item order', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpBar(tester, const JellyTabBarHeadless(items: _items));

        final home = focusOfTab(tester, 'Home')..requestFocus();
        await tester.pump();
        expect(home.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        final search = focusOfTab(tester, 'Search');
        expect(search.hasFocus, isTrue);
        expect(home.hasFocus, isFalse);
        handle.dispose();
      });

      testWidgets('arrow right moves focus to the next tab', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpBar(tester, const JellyTabBarHeadless(items: _items));

        final home = focusOfTab(tester, 'Home')..requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(focusOfTab(tester, 'Search').hasFocus, isTrue);
        expect(home.hasFocus, isFalse);
        handle.dispose();
      });

      testWidgets('arrow left moves focus back to the previous tab', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpBar(tester, const JellyTabBarHeadless(items: _items));

        final search = focusOfTab(tester, 'Search')..requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        expect(focusOfTab(tester, 'Home').hasFocus, isTrue);
        expect(search.hasFocus, isFalse);
        handle.dispose();
      });

      testWidgets('enter activates the focused tab', (tester) async {
        final handle = tester.ensureSemantics();
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

        focusOfTab(tester, 'Search').requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settle(tester);

        expect(pressEvents, hasLength(1));
        expect(pressEvents.single.index, 1);
        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
        handle.dispose();
      });

      testWidgets('space activates the focused tab and selects it', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabChange: changeEvents.add),
        );

        focusOfTab(tester, 'Search').requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await settle(tester);

        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
        final searchTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Search'),
        );
        expect(searchTab.properties.selected, isTrue);
        handle.dispose();
      });

      testWidgets('activating the already-selected tab does not re-fire '
          'onTabChange', (tester) async {
        final handle = tester.ensureSemantics();
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabChange: changeEvents.add),
        );

        focusOfTab(tester, 'Home').requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settle(tester);

        expect(changeEvents, isEmpty);
        handle.dispose();
      });

      testWidgets('keyboard activation respects a rejecting onTabPress', (
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

        focusOfTab(tester, 'Search').requestFocus();
        await tester.pump();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await settle(tester);

        expect(changeEvents, isEmpty);
        final homeTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Home'),
        );
        expect(homeTab.properties.selected, isTrue);
        handle.dispose();
      });

      testWidgets('physical taps still reach the pointer listener while '
          'a tab is focused', (tester) async {
        final handle = tester.ensureSemantics();
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabChange: changeEvents.add),
        );

        final home = focusOfTab(tester, 'Home')..requestFocus();
        await tester.pump();
        expect(home.hasFocus, isTrue);

        await tester.tap(find.byType(JellyTabBarHeadless));
        await settle(tester);

        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
        handle.dispose();
      });

      testWidgets('dispatches ButtonActivateIntent on web-style activation', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        final changeEvents = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabChange: changeEvents.add),
        );

        final searchTab = tester.element(find.bySemanticsLabel('Search'));
        final invoked = Actions.maybeInvoke(
          searchTab,
          const ButtonActivateIntent(),
        );

        expect(invoked, isNull);
        await settle(tester);
        expect(changeEvents, hasLength(1));
        expect(changeEvents.single.index, 1);
        handle.dispose();
      });

      testWidgets('invoking the semantics long-press action fires '
          'onTabLongPress', (tester) async {
        final handle = tester.ensureSemantics();
        final longPresses = <JellyTabsChangeEvent>[];
        await pumpBar(
          tester,
          JellyTabBarHeadless(items: _items, onTabLongPress: longPresses.add),
        );

        final homeTab = tester.widget<Semantics>(
          find.bySemanticsLabel('Home'),
        );
        homeTab.properties.onLongPress!.call();
        await tester.pump();

        expect(longPresses, hasLength(1));
        expect(longPresses.single.index, 0);
        handle.dispose();
      });
    });
  });
}
