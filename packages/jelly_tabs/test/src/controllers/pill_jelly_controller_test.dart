import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/controllers/pill_jelly_controller.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_change_event.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_icon_props.dart';
import 'package:jelly_tabs/src/models/jelly_tabs_item.dart';

Widget _icon(JellyTabsIconProps props) => const SizedBox();

List<JellyTabsItem> _items(int count) => List.generate(
  count,
  (i) => JellyTabsItem(
    key: 'item-$i',
    label: 'Item $i',
    activeIcon: _icon,
    inactiveIcon: _icon,
  ),
);

void main() {
  // Pumps enough frames for the ticker-driven frame loop to accumulate
  // elapsed time past its 500ms idle deadline and self-stop, and for the
  // distortion springs to settle.
  Future<void> pumpFrames(
    WidgetTester tester, {
    int frames = 64,
    Duration perFrame = const Duration(milliseconds: 16),
  }) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(perFrame);
    }
  }

  group(PillJellyController, () {
    late List<JellyTabsItem> items;
    late bool? Function(JellyTabsChangeEvent event)? onTabPress;
    late void Function(JellyTabsChangeEvent event)? onTabChange;

    setUp(() {
      items = _items(4);
      onTabPress = null;
      onTabChange = null;
    });

    PillJellyController buildSubject({int? selectedIndex}) {
      return PillJellyController(
        items: items,
        vsync: TestVSync(),
        selectedIndex: selectedIndex,
        onTabPress: onTabPress,
        onTabChange: onTabChange,
      );
    }

    group('setTrackWidth', () {
      test('computes correct tab width', () {
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);

        // (400 - 2*4) / 4 = 98
        expect(subject.trackWidth, 400);
        expect(
          subject.pillMaskTranslation,
          Offset.zero,
        );
      });
    });

    group('controlled selection', () {
      testWidgets('animates value toward controlled index', (tester) async {
        final subject = buildSubject(selectedIndex: 0);
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        subject.setControlledSelectedIndex(3);
        await pumpFrames(tester);

        // (400-8)/4 = 98 → index 3 → x = 294
        expect(subject.pillMaskTranslation.dx, closeTo(294, 1e-3));
      });
    });

    group('beginGesture', () {
      testWidgets('snaps target toward touched tab with snapOnPointerDown', (
        tester,
      ) async {
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        // tabWidth = 98; tapping at x=150 → floor((150-4)/98)=1
        subject.beginGesture(150, 30, 150);

        expect(subject.frameState.isDragging, 1);
        expect(subject.frameState.pressTarget, 1);
        expect(subject.frameState.shapeTarget, 1.3);
        expect(subject.frameState.targetValue, 1);
        subject.finishGesture();
        await pumpFrames(tester);
      });
    });

    group('updateGesture', () {
      testWidgets('moves targetValue by horizontal translation / tabWidth', (
        tester,
      ) async {
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        subject.beginGesture(150, 30, 150);
        // drag +98px = +1 tab from snap point 1 → 2
        subject.updateGesture(98, 0, 150, 150);

        expect(subject.frameState.targetValue, closeTo(2, 1e-6));
        subject.finishGesture();
        await pumpFrames(tester);
      });
    });

    group('finishGesture', () {
      testWidgets('stationary tap selects the touched tab', (tester) async {
        onTabChange = (_) {};
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        subject.beginGesture(150, 30, 150);
        subject.finishGesture();

        expect(subject.selectedIndex, 1);
        await pumpFrames(tester);
      });

      testWidgets('drag settles to the nearest tab index', (tester) async {
        onTabChange = (_) {};
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        subject.beginGesture(150, 30, 150);
        subject.updateGesture(120, 0, 150, 150);
        subject.finishGesture();

        // dragStartTarget=1, +120/98≈1.22 → targetValue≈2.22 → round=2
        expect(subject.selectedIndex, 2);
        await pumpFrames(tester);
      });

      testWidgets(
        'rejected press restores prior selection and fires no change',
        (
          tester,
        ) async {
          onTabPress = (_) => false;
          var changeCount = 0;
          onTabChange = (_) => changeCount++;
          final subject = buildSubject(selectedIndex: 0);
          addTearDown(subject.dispose);

          subject.setTrackWidth(400);
          await tester.pump();

          subject.beginGesture(150, 30, 150);
          subject.finishGesture();

          expect(subject.selectedIndex, 0);
          expect(changeCount, 0);
          expect(subject.frameState.targetValue, 0);
          await pumpFrames(tester);
        },
      );

      testWidgets('accepted change fires onTabChange', (tester) async {
        final events = <JellyTabsChangeEvent>[];
        onTabChange = events.add;
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        subject.beginGesture(150, 30, 150);
        subject.finishGesture();

        expect(events, hasLength(1));
        expect(events.first.index, 1);
        await pumpFrames(tester);
      });
    });

    group('frame loop', () {
      testWidgets('settles to inactive after 500ms idle', (tester) async {
        final subject = buildSubject();
        addTearDown(subject.dispose);

        subject.setTrackWidth(400);
        await tester.pump();

        subject.beginGesture(150, 30, 150);
        await tester.pump(const Duration(milliseconds: 16));
        expect(subject.isFrameLoopActive, isTrue);

        subject.finishGesture();
        await pumpFrames(tester, frames: 40);

        expect(subject.isFrameLoopActive, isFalse);
      });
    });
  });
}
