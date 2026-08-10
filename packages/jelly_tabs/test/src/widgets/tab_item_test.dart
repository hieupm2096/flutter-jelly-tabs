import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_icon_props.dart';
import 'package:jelly_tabs/src/widgets/tab_item.dart';

import '../../helpers/pump_app.dart';

const _colors = JellyTabsColors(
  activeContent: Color(0xFF11100F),
  inactiveContent: Color(0xFFB8B4AD),
  selectedSurface: Color(0xFFF2EEE7),
  surface: Color(0xFF22211F),
);

Widget _starIcon(JellyTabsIconProps props) =>
    Icon(Icons.star, color: props.color, size: props.size);

Widget _starBorderIcon(JellyTabsIconProps props) =>
    Icon(Icons.star_border, color: props.color, size: props.size);

void main() {
  group(TabItem, () {
    group('renders', () {
      testWidgets('the active icon and a bold label when active', (
        tester,
      ) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
            isActive: true,
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(Icons.star_border), findsNothing);
        expect(
          tester.widget<Text>(find.text('Home')).style?.fontWeight,
          FontWeight.w700,
        );
      });

      testWidgets('the inactive icon and a regular label when not active', (
        tester,
      ) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
          ),
        );

        expect(find.byIcon(Icons.star_border), findsOneWidget);
        expect(find.byIcon(Icons.star), findsNothing);
        expect(
          tester.widget<Text>(find.text('Home')).style?.fontWeight,
          FontWeight.w400,
        );
      });
    });

    group('colors', () {
      testWidgets('the active icon and label with activeColor when active', (
        tester,
      ) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
            activeColor: Color(0xFF11100F),
            inactiveColor: Color(0xFFB8B4AD),
            isActive: true,
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(icon.color, const Color(0xFF11100F));

        final label = tester.widget<Text>(find.text('Home'));
        expect(label.style?.color, const Color(0xFF11100F));
      });

      testWidgets('the inactive icon and label with inactiveColor', (
        tester,
      ) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
            activeColor: Color(0xFF11100F),
            inactiveColor: Color(0xFFB8B4AD),
          ),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.star_border));
        expect(icon.color, const Color(0xFFB8B4AD));

        final label = tester.widget<Text>(find.text('Home'));
        expect(label.style?.color, const Color(0xFFB8B4AD));
      });
    });

    group('label', () {
      testWidgets('applies labelStyle over the base label style', (
        tester,
      ) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
            labelStyle: TextStyle(fontSize: 20, color: Color(0xFF00FF00)),
          ),
        );

        final label = tester.widget<Text>(find.text('Home'));
        expect(label.style?.fontSize, 20);
        expect(label.style?.color, const Color(0xFF00FF00));
      });
    });

    group('badge', () {
      testWidgets('renders the badge when provided', (tester) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
            badge: 3,
          ),
        );

        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('is hidden when not provided', (tester) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
          ),
        );

        expect(find.byType(Positioned), findsNothing);
      });
    });

    group('displayScale', () {
      testWidgets('scales item height, icon offset, and label font', (
        tester,
      ) async {
        await tester.pumpAppWidget(
          const TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: _starIcon,
            inactiveIcon: _starBorderIcon,
            displayScale: 2,
          ),
        );

        final item = tester.widget<SizedBox>(
          find
              .descendant(
                of: find.byType(TabItem),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(item.height, 112);

        final transform = tester.widget<Transform>(
          find
              .descendant(
                of: find.byType(TabItem),
                matching: find.byType(Transform),
              )
              .first,
        );
        expect(transform.transform, Matrix4.translationValues(0, 4, 0));

        final label = tester.widget<Text>(find.text('Home'));
        expect(label.style?.fontSize, 26);
      });
    });

    group('icon builder', () {
      testWidgets('receives the resolved color, size, opacity, and colors', (
        tester,
      ) async {
        JellyTabsIconProps? received;
        await tester.pumpAppWidget(
          TabItem(
            text: 'Home',
            colors: _colors,
            activeIcon: (props) {
              received = props;
              return _starIcon(props);
            },
            inactiveIcon: _starBorderIcon,
            activeColor: const Color(0xFF11100F),
            activeOpacity: 0.7,
            isActive: true,
          ),
        );

        expect(received, isNotNull);
        expect(received!.color, const Color(0xFF11100F));
        expect(received!.colors, _colors);
        expect(received!.opacity, 0.7);
        expect(received!.size, 28);
      });
    });
  });
}
