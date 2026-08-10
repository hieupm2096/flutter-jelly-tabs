import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_tags.dart';

Widget _homeActive(JellyTabsIconProps props) =>
    Icon(Icons.home_filled, color: props.color, size: props.size);

Widget _homeInactive(JellyTabsIconProps props) =>
    Icon(Icons.home, color: props.color, size: props.size);

Widget _searchActive(JellyTabsIconProps props) =>
    Icon(Icons.search, color: props.color, size: props.size);

Widget _searchInactive(JellyTabsIconProps props) =>
    Icon(Icons.search_off, color: props.color, size: props.size);

Widget _favoriteActive(JellyTabsIconProps props) =>
    Icon(Icons.favorite, color: props.color, size: props.size);

Widget _favoriteInactive(JellyTabsIconProps props) =>
    Icon(Icons.favorite_border, color: props.color, size: props.size);

Widget _personActive(JellyTabsIconProps props) =>
    Icon(Icons.person, color: props.color, size: props.size);

Widget _personInactive(JellyTabsIconProps props) =>
    Icon(Icons.person_outline, color: props.color, size: props.size);

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
  JellyTabsItem(
    key: 'favorite',
    label: 'Favorite',
    activeIcon: _favoriteActive,
    inactiveIcon: _favoriteInactive,
  ),
  JellyTabsItem(
    key: 'person',
    label: 'Person',
    activeIcon: _personActive,
    inactiveIcon: _personInactive,
  ),
];

const _badgedItems = [
  JellyTabsItem(
    key: 'home',
    label: 'Home',
    badge: 3,
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

Future<void> pumpGolden(WidgetTester tester, Widget bar) async {
  await tester.pumpAppWidget(bar);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
}

void main() {
  group(JellyTabBarHeadless, () {
    testWidgets(
      'matches the rest-state golden',
      tags: TestTag.golden,
      (tester) async {
        await pumpGolden(tester, const JellyTabBarHeadless(items: _items));

        await expectLater(
          find.byType(JellyTabBarHeadless),
          matchesGoldenFile('../../goldens/rest.png'),
        );
      },
    );

    testWidgets(
      'matches the selected-state golden',
      tags: TestTag.golden,
      (tester) async {
        await pumpGolden(
          tester,
          const JellyTabBarHeadless(items: _items, selectedIndex: 2),
        );

        await expectLater(
          find.byType(JellyTabBarHeadless),
          matchesGoldenFile('../../goldens/selected.png'),
        );
      },
    );

    testWidgets(
      'matches the pressed golden',
      tags: TestTag.golden,
      (tester) async {
        await pumpGolden(tester, const JellyTabBarHeadless(items: _items));

        final gesture = await tester.startGesture(const Offset(400, 300));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }

        await expectLater(
          find.byType(JellyTabBarHeadless),
          matchesGoldenFile('../../goldens/pressed.png'),
        );

        await gesture.up();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
      },
    );

    testWidgets(
      'matches the badge golden',
      tags: TestTag.golden,
      (tester) async {
        await pumpGolden(
          tester,
          const JellyTabBarHeadless(items: _badgedItems),
        );

        await expectLater(
          find.byType(JellyTabBarHeadless),
          matchesGoldenFile('../../goldens/badge.png'),
        );
      },
    );
  });
}
