import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_change_event.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_icon_props.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_item.dart';

const _defaultColors = JellyTabsColors(
  activeContent: Color(0xFF11100F),
  inactiveContent: Color(0xFFB8B4AD),
  selectedSurface: Color(0xFFF2EEE7),
  surface: Color(0xFF22211F),
);

Widget _testIcon(JellyTabsIconProps props) => const SizedBox();

void main() {
  group(JellyTabsIconProps, () {
    test('holds color, colors, opacity, and size', () {
      const props = JellyTabsIconProps(
        color: Color(0xFF11100F),
        colors: _defaultColors,
        opacity: 1,
        size: 28,
      );

      expect(props.color, equals(const Color(0xFF11100F)));
      expect(props.colors, equals(_defaultColors));
      expect(props.opacity, 1);
      expect(props.size, 28);
    });

    test('implements value equality', () {
      const a = JellyTabsIconProps(
        color: Color(0xFF11100F),
        colors: _defaultColors,
        opacity: 1,
        size: 28,
      );
      const b = JellyTabsIconProps(
        color: Color(0xFF11100F),
        colors: _defaultColors,
        opacity: 1,
        size: 28,
      );

      expect(a, equals(b));
    });
  });

  group(JellyTabsItem, () {
    test('holds key, label, icons, and optional fields', () {
      final item = JellyTabsItem(
        key: 'home',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
        accessibilityLabel: 'Home tab',
        badge: '3',
        testID: const Key('home-tab'),
      );

      expect(item.key, 'home');
      expect(item.label, 'Home');
      expect(item.accessibilityLabel, 'Home tab');
      expect(item.badge, '3');
      expect(item.testID, equals(const Key('home-tab')));
    });

    test('badge accepts number', () {
      final item = JellyTabsItem(
        key: 'notifications',
        label: 'Notifications',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
        badge: 5,
      );

      expect(item.badge, 5);
    });

    test('implements value equality', () {
      final a = JellyTabsItem(
        key: 'home',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
      );
      final b = JellyTabsItem(
        key: 'home',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
      );

      expect(a, equals(b));
    });

    test('different keys are not equal', () {
      final a = JellyTabsItem(
        key: 'home',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
      );
      final b = JellyTabsItem(
        key: 'search',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
      );

      expect(a, isNot(equals(b)));
    });
  });

  group(JellyTabsChangeEvent, () {
    test('holds index and item', () {
      final item = JellyTabsItem(
        key: 'home',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
      );
      final event = JellyTabsChangeEvent(index: 0, item: item);

      expect(event.index, 0);
      expect(event.item, equals(item));
    });

    test('implements value equality', () {
      final item = JellyTabsItem(
        key: 'home',
        label: 'Home',
        activeIcon: _testIcon,
        inactiveIcon: _testIcon,
      );
      final a = JellyTabsChangeEvent(index: 0, item: item);
      final b = JellyTabsChangeEvent(index: 0, item: item);

      expect(a, equals(b));
    });
  });
}
