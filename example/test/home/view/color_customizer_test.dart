import 'package:example/home/view/color_customizer/color_customizer.dart';
import 'package:example/home/view/color_customizer/palettes.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/jelly_tabs.dart';

import '../../helpers/helpers.dart';

Future<void> pumpCustomizer(
  WidgetTester tester, {
  required ColorCustomizer customizer,
}) async {
  await tester.pumpApp(
    Scaffold(body: SingleChildScrollView(child: customizer)),
  );
}

ColorCustomizer buildCustomizer({
  ValueChanged<JellyTabsColors>? onColorsChange,
  ValueChanged<JellyTabsConfig>? onConfigChange,
  ValueChanged<JellyTabsOpacity>? onOpacityChange,
  VoidCallback? onReset,
}) {
  return ColorCustomizer(
    blur: kInitialBlur,
    colors: kInitialColors,
    config: resolveJellyTabsConfig(),
    onBlurChange: (_) {},
    onColorsChange: onColorsChange ?? (_) {},
    onConfigChange: onConfigChange ?? (_) {},
    onOpacityChange: onOpacityChange ?? (_) {},
    onReset: onReset ?? () {},
    onShuffleBackground: () {},
    onTouchFeedbackColorChange: (_) {},
    opacity: kThemeOpacity,
    touchFeedbackColor: kInitialColors.selectedSurface,
  );
}

Future<void> expandPanel(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

void main() {
  group(ColorCustomizer, () {
    testWidgets('renders the header and action buttons', (tester) async {
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onColorsChange: (_) {}),
      );

      expect(find.text('flutter-jelly-tabs'), findsOneWidget);
      expect(find.text('Change bg'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('renders all palette presets in the Palette panel', (
      tester,
    ) async {
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onColorsChange: (_) {}),
      );
      await expandPanel(tester, 'Palette');

      for (final palette in kPalettes) {
        expect(
          find.byKey(Key('palette-${palette.label}')),
          findsOneWidget,
          reason: 'missing ${palette.label}',
        );
      }
    });

    testWidgets('applying a palette emits colors, opacity, and touch color', (
      tester,
    ) async {
      final colorsChanges = <JellyTabsColors>[];
      final opacityChanges = <JellyTabsOpacity>[];
      Color? touchColor;
      await pumpCustomizer(
        tester,
        customizer: ColorCustomizer(
          blur: kInitialBlur,
          colors: kInitialColors,
          config: resolveJellyTabsConfig(),
          onBlurChange: (_) {},
          onColorsChange: colorsChanges.add,
          onConfigChange: (_) {},
          onOpacityChange: opacityChanges.add,
          onReset: () {},
          onShuffleBackground: () {},
          onTouchFeedbackColorChange: (color) => touchColor = color,
          opacity: kThemeOpacity,
          touchFeedbackColor: kInitialColors.selectedSurface,
        ),
      );
      await expandPanel(tester, 'Palette');

      await tester.tap(find.byKey(const Key('palette-Blue')));
      await tester.pump();

      expect(colorsChanges, hasLength(1));
      expect(colorsChanges.single.selectedSurface, const Color(0xFF2563EB));
      expect(opacityChanges, hasLength(1));
      expect(opacityChanges.single.surface, 0.78);
      expect(touchColor, const Color(0xFF2563EB));
    });

    testWidgets('editing a hex color emits an updated colors value', (
      tester,
    ) async {
      final colorsChanges = <JellyTabsColors>[];
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onColorsChange: colorsChanges.add),
      );
      await expandPanel(tester, 'Palette');

      await tester.tap(find.byKey(const Key('hex-surface')));
      await tester.enterText(find.byKey(const Key('hex-surface')), '123456');
      await tester.pump();

      expect(colorsChanges, hasLength(1));
      expect(colorsChanges.single.surface, const Color(0xFF123456));
    });

    testWidgets('changing an opacity slider emits an opacity update', (
      tester,
    ) async {
      final opacityChanges = <JellyTabsOpacity>[];
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onOpacityChange: opacityChanges.add),
      );
      await expandPanel(tester, 'Palette');

      await tester.drag(
        find.byType(Slider).first,
        const Offset(40, 0),
      );
      await tester.pump();

      expect(opacityChanges, isNotEmpty);
    });

    testWidgets('layout panel updates the config on geometry change', (
      tester,
    ) async {
      final configChanges = <JellyTabsConfig>[];
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onConfigChange: configChanges.add),
      );
      await expandPanel(tester, 'Layout');

      await tester.drag(find.byType(Slider).first, const Offset(40, 0));
      await tester.pump();

      expect(configChanges, isNotEmpty);
      expect(
        configChanges.first.layout.iconSize,
        isNot(resolveJellyTabsConfig().layout.iconSize),
      );
    });

    testWidgets('motion panel toggles snap on pointer down', (tester) async {
      final configChanges = <JellyTabsConfig>[];
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onConfigChange: configChanges.add),
      );
      await expandPanel(tester, 'Motion');

      await tester.tap(find.text('Snap on pointer down'));
      await tester.pump();

      expect(configChanges, hasLength(1));
      expect(
        configChanges.single.pillJelly.snapOnPointerDown,
        isFalse,
      );
    });

    testWidgets('touch panel exposes distortion controls', (tester) async {
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(onColorsChange: (_) {}),
      );
      await expandPanel(tester, 'Touch');

      expect(find.text('Press transform'), findsOneWidget);
      expect(find.text('Distortion spring'), findsOneWidget);
      expect(find.text('Vertical drag'), findsOneWidget);
    });

    testWidgets('reset fires the reset callback', (tester) async {
      var resetCount = 0;
      await pumpCustomizer(
        tester,
        customizer: buildCustomizer(
          onColorsChange: (_) {},
          onReset: () => resetCount++,
        ),
      );

      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(resetCount, 1);
    });
  });
}
