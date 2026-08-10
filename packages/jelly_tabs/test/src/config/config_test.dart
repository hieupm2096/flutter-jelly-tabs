import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/config.dart';
import 'package:jelly_tabs/src/config/spring_config.dart';

void main() {
  group(JellyTabsLayout, () {
    test('holds all layout fields', () {
      const layout = JellyTabsLayout(
        iconSize: 28,
        itemHeight: 56,
        maskOverscanX: 48,
        maskOverscanY: 16,
        trackHeight: 64,
        trackInset: 4,
      );

      expect(layout.iconSize, 28);
      expect(layout.itemHeight, 56);
    });

    test('implements value equality', () {
      const a = JellyTabsLayout(
        iconSize: 28,
        itemHeight: 56,
        maskOverscanX: 48,
        maskOverscanY: 16,
        trackHeight: 64,
        trackInset: 4,
      );
      const b = JellyTabsLayout(
        iconSize: 28,
        itemHeight: 56,
        maskOverscanX: 48,
        maskOverscanY: 16,
        trackHeight: 64,
        trackInset: 4,
      );

      expect(a, equals(b));
    });
  });

  group(JellyTabsColors, () {
    test('implements value equality', () {
      const a = JellyTabsColors(
        activeContent: Color(0xFF11100F),
        inactiveContent: Color(0xFFB8B4AD),
        selectedSurface: Color(0xFFF2EEE7),
        surface: Color(0xFF22211F),
      );
      const b = JellyTabsColors(
        activeContent: Color(0xFF11100F),
        inactiveContent: Color(0xFFB8B4AD),
        selectedSurface: Color(0xFFF2EEE7),
        surface: Color(0xFF22211F),
      );

      expect(a, equals(b));
    });

    test('different colors are not equal', () {
      const a = JellyTabsColors(
        activeContent: Color(0xFF11100F),
        inactiveContent: Color(0xFFB8B4AD),
        selectedSurface: Color(0xFFF2EEE7),
        surface: Color(0xFF22211F),
      );
      const b = JellyTabsColors(
        activeContent: Color(0xFFFFFFFF),
        inactiveContent: Color(0xFFB8B4AD),
        selectedSurface: Color(0xFFF2EEE7),
        surface: Color(0xFF22211F),
      );

      expect(a, isNot(equals(b)));
    });
  });

  group(JellyTabsOpacity, () {
    test('implements value equality', () {
      const a = JellyTabsOpacity(
        activeContent: 1,
        inactiveContent: 0.5,
        selectedSurface: 1,
        surface: 0.8,
      );
      const b = JellyTabsOpacity(
        activeContent: 1,
        inactiveContent: 0.5,
        selectedSurface: 1,
        surface: 0.8,
      );

      expect(a, equals(b));
    });
  });

  group(PillJellyFrameConfig, () {
    test('implements value equality', () {
      const springs = PillJellySpringsConfig(
        panel: SpringConfig(stiffness: 300, dampingRatio: 1),
        press: SpringConfig(stiffness: 1000, dampingRatio: 1),
        scaleX: SpringConfig(stiffness: 250, dampingRatio: 0.6),
        scaleY: SpringConfig(stiffness: 250, dampingRatio: 0.7),
        value: SpringConfig(stiffness: 1000, dampingRatio: 1),
        velocity: SpringConfig(stiffness: 300, dampingRatio: 0.5),
      );
      const a = PillJellyFrameConfig(
        releaseDistanceFraction: 0.025,
        springs: springs,
      );
      const b = PillJellyFrameConfig(
        releaseDistanceFraction: 0.025,
        springs: springs,
      );

      expect(a, equals(b));
    });
  });

  group(PillJellyConfig, () {
    test('implements value equality', () {
      const frameConfig = PillJellyFrameConfig(
        releaseDistanceFraction: 0.025,
        springs: PillJellySpringsConfig(
          panel: SpringConfig(stiffness: 300, dampingRatio: 1),
          press: SpringConfig(stiffness: 1000, dampingRatio: 1),
          scaleX: SpringConfig(stiffness: 250, dampingRatio: 0.6),
          scaleY: SpringConfig(stiffness: 250, dampingRatio: 0.7),
          value: SpringConfig(stiffness: 1000, dampingRatio: 1),
          velocity: SpringConfig(stiffness: 300, dampingRatio: 0.5),
        ),
      );
      const a = PillJellyConfig(
        pressedScale: 1.3,
        snapOnPointerDown: true,
        frameConfig: frameConfig,
      );
      const b = PillJellyConfig(
        pressedScale: 1.3,
        snapOnPointerDown: true,
        frameConfig: frameConfig,
      );

      expect(a, equals(b));
    });
  });

  group(DistortionConfig, () {
    test('implements value equality', () {
      const a = DistortionConfig(
        pressedScale: 1.025,
        touchFeedback: TouchFeedbackConfig(
          middleOpacityRatio: 0.43,
          opacity: 0.15,
          radius: 150,
          scale: 2,
        ),
        spring:
            DistortionSpringConfig(damping: 18, mass: 0.9, stiffness: 240),
        verticalDrag: VerticalDragConfig(
          distortion: 0.08,
          distanceForMaxDistortion: 700,
          follow: 0.25,
          rubberBand: 0.14,
        ),
      );
      const b = DistortionConfig(
        pressedScale: 1.025,
        touchFeedback: TouchFeedbackConfig(
          middleOpacityRatio: 0.43,
          opacity: 0.15,
          radius: 150,
          scale: 2,
        ),
        spring:
            DistortionSpringConfig(damping: 18, mass: 0.9, stiffness: 240),
        verticalDrag: VerticalDragConfig(
          distortion: 0.08,
          distanceForMaxDistortion: 700,
          follow: 0.25,
          rubberBand: 0.14,
        ),
      );

      expect(a, equals(b));
    });
  });

  group('resolveJellyTabsConfig', () {
    test('returns all defaults when no override', () {
      final config = resolveJellyTabsConfig();

      expect(config.layout.iconSize, 28);
      expect(config.layout.itemHeight, 56);
      expect(config.pillJelly.pressedScale, 1.3);
      expect(config.distortion.pressedScale, 1.025);
    });

    test('layout override keeps sibling defaults', () {
      final config = resolveJellyTabsConfig(
        JellyTabsConfigOverride(
          layout: JellyTabsLayoutOverride(trackHeight: 80),
        ),
      );

      expect(config.layout.trackHeight, 80);
      expect(config.layout.iconSize, 28);
      expect(config.layout.itemHeight, 56);
      expect(config.layout.maskOverscanX, 48);
    });

    test('nested spring override keeps other springs', () {
      final config = resolveJellyTabsConfig(
        JellyTabsConfigOverride(
          pillJelly: PillJellyConfigOverride(
            frameConfig: PillJellyFrameConfigOverride(
              springs: PillJellySpringsConfigOverride(
                panel: SpringConfig(stiffness: 500, dampingRatio: 0.8),
              ),
            ),
          ),
        ),
      );

      expect(config.pillJelly.frameConfig.springs.panel.stiffness, 500);
      expect(config.pillJelly.frameConfig.springs.panel.dampingRatio, 0.8);
      expect(config.pillJelly.frameConfig.springs.press.stiffness, 1000);
      expect(config.pillJelly.frameConfig.springs.press.dampingRatio, 1);
      expect(config.pillJelly.frameConfig.springs.scaleX.stiffness, 250);
    });

    test('distortion verticalDrag follow override keeps other distortion', () {
      final config = resolveJellyTabsConfig(
        JellyTabsConfigOverride(
          distortion: DistortionConfigOverride(
            verticalDrag: VerticalDragConfigOverride(follow: 0.5),
          ),
        ),
      );

      expect(config.distortion.verticalDrag.follow, 0.5);
      expect(config.distortion.verticalDrag.distortion, 0.08);
      expect(config.distortion.verticalDrag.rubberBand, 0.14);
      expect(config.distortion.pressedScale, 1.025);
      expect(config.distortion.touchFeedback.opacity, 0.15);
    });

    test('full override replaces all values', () {
      final config = resolveJellyTabsConfig(
        JellyTabsConfigOverride(
          distortion: DistortionConfigOverride(
            pressedScale: 2,
            touchFeedback: TouchFeedbackConfigOverride(
              middleOpacityRatio: 0.5,
              opacity: 0.3,
              radius: 200,
              scale: 3,
            ),
            spring:
                DistortionSpringConfig(damping: 10, mass: 0.5, stiffness: 100),
            verticalDrag: VerticalDragConfigOverride(
              distortion: 0.1,
              distanceForMaxDistortion: 500,
              follow: 0.3,
              rubberBand: 0.2,
            ),
          ),
        ),
      );

      expect(config.distortion.pressedScale, 2);
      expect(config.distortion.touchFeedback.middleOpacityRatio, 0.5);
      expect(config.distortion.spring.damping, 10);
      expect(config.distortion.verticalDrag.distortion, 0.1);
    });
  });
}
