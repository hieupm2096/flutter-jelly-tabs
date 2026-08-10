import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/widgets/pill_masked_view.dart';
import 'package:jelly_tabs/src/widgets/pill_path_clipper.dart';

import '../../helpers/pump_app.dart';

const _clipper = PillPathClipper(
  translationX: 0,
  scaleX: 1,
  scaleY: 1,
  tabWidth: 98,
  itemHeight: 56,
  left: 52,
  top: 20,
);

void main() {
  group(PillPathClipper, () {
    group('getClip', () {
      test('produces a capsule at the pill position with the tab size', () {
        final path = _clipper.getClip(const Size(496, 96));

        final bounds = path.getBounds();
        expect(bounds, const Rect.fromLTWH(52, 20, 98, 56));

        const center = Offset(52 + 49, 20 + 28);
        expect(path.contains(center), isTrue);
        expect(path.contains(const Offset(52 + 1, 20 + 1)), isFalse);
        expect(path.contains(const Offset(52 + 28, 20 + 1)), isTrue);
      });

      test('translates and scales about the pill center', () {
        const clipper = PillPathClipper(
          translationX: 98,
          scaleX: 1.2,
          scaleY: 0.8,
          tabWidth: 98,
          itemHeight: 56,
          left: 52,
          top: 20,
        );

        final path = clipper.getClip(const Size(496, 96));
        final bounds = path.getBounds();

        const center = Offset(52 + 98 + 49, 20 + 28);
        expect(bounds.left, closeTo(center.dx - 98 * 1.2 / 2, 1e-3));
        expect(bounds.top, closeTo(center.dy - 56 * 0.8 / 2, 1e-3));
        expect(bounds.width, closeTo(98 * 1.2, 1e-3));
        expect(bounds.height, closeTo(56 * 0.8, 1e-3));
        expect(path.contains(center), isTrue);
      });
    });

    group('shouldReclip', () {
      test('returns false when the pill values are unchanged', () {
        expect(_clipper.shouldReclip(_clipper), isFalse);
      });

      test('returns true when any pill value changes', () {
        const moved = PillPathClipper(
          translationX: 98,
          scaleX: 1,
          scaleY: 1,
          tabWidth: 98,
          itemHeight: 56,
          left: 52,
          top: 20,
        );

        expect(moved.shouldReclip(_clipper), isTrue);
      });
    });
  });

  group(PillMaskedView, () {
    testWidgets('clips its child to the pill path', (tester) async {
      await tester.pumpAppWidget(
        const PillMaskedView(
          translationX: 98,
          scaleX: 1.2,
          scaleY: 0.8,
          tabWidth: 98,
          itemHeight: 56,
          left: 52,
          top: 20,
          child: ColoredBox(color: Color(0xFFFF0000)),
        ),
      );

      expect(find.byType(ClipPath), findsOneWidget);
      final clip = tester.widget<ClipPath>(find.byType(ClipPath));
      final clipper = clip.clipper!;
      expect(clipper, isA<PillPathClipper>());
      expect(clipper.shouldReclip(_clipper), isTrue);
    });

    testWidgets('renders nothing when not visible', (tester) async {
      await tester.pumpAppWidget(
        const PillMaskedView(
          translationX: 0,
          scaleX: 1,
          scaleY: 1,
          tabWidth: 98,
          itemHeight: 56,
          left: 52,
          top: 20,
          visible: false,
          child: ColoredBox(color: Color(0xFFFF0000)),
        ),
      );

      expect(find.byType(ClipPath), findsNothing);
    });
  });
}
