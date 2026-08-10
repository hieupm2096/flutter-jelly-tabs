import 'package:flutter_test/flutter_test.dart';
import 'package:jelly_tabs/src/config/defaults.dart';

void main() {
  group(DefaultJellyTabsLayout, () {
    test('iconSize is 28', () {
      expect(DefaultJellyTabsLayout.iconSize, 28);
    });

    test('itemHeight is 56', () {
      expect(DefaultJellyTabsLayout.itemHeight, 56);
    });

    test('maskOverscanX is 48', () {
      expect(DefaultJellyTabsLayout.maskOverscanX, 48);
    });

    test('maskOverscanY is 16', () {
      expect(DefaultJellyTabsLayout.maskOverscanY, 16);
    });

    test('trackHeight is 64', () {
      expect(DefaultJellyTabsLayout.trackHeight, 64);
    });

    test('trackInset is 4', () {
      expect(DefaultJellyTabsLayout.trackInset, 4);
    });
  });

  group(DefaultJellyTabsColors, () {
    test('activeContent is #11100F', () {
      expect(
        DefaultJellyTabsColors.activeContent.toARGB32(),
        0xFF11100F,
      );
    });

    test('inactiveContent is #B8B4AD', () {
      expect(
        DefaultJellyTabsColors.inactiveContent.toARGB32(),
        0xFFB8B4AD,
      );
    });

    test('selectedSurface is #F2EEE7', () {
      expect(
        DefaultJellyTabsColors.selectedSurface.toARGB32(),
        0xFFF2EEE7,
      );
    });

    test('surface is #22211F', () {
      expect(
        DefaultJellyTabsColors.surface.toARGB32(),
        0xFF22211F,
      );
    });
  });

  group(DefaultJellyTabsOpacity, () {
    test('all opacity values are 1', () {
      expect(DefaultJellyTabsOpacity.activeContent, 1);
      expect(DefaultJellyTabsOpacity.inactiveContent, 1);
      expect(DefaultJellyTabsOpacity.selectedSurface, 1);
      expect(DefaultJellyTabsOpacity.surface, 1);
    });
  });

  group(DefaultPillJelly, () {
    test('pressedScale is 1.3', () {
      expect(DefaultPillJelly.pressedScale, 1.3);
    });

    test('snapOnPointerDown is true', () {
      expect(DefaultPillJelly.snapOnPointerDown, isTrue);
    });

    group('frameConfig', () {
      test('releaseDistanceFraction is 0.025', () {
        expect(DefaultPillJelly.frameConfig.releaseDistanceFraction, 0.025);
      });

      group('springs', () {
        test('panel is {stiffness: 300, dampingRatio: 1}', () {
          expect(DefaultPillJelly.frameConfig.springs.panel.stiffness, 300);
          expect(DefaultPillJelly.frameConfig.springs.panel.dampingRatio, 1);
        });

        test('press is {stiffness: 1000, dampingRatio: 1}', () {
          expect(DefaultPillJelly.frameConfig.springs.press.stiffness, 1000);
          expect(DefaultPillJelly.frameConfig.springs.press.dampingRatio, 1);
        });

        test('scaleX is {stiffness: 250, dampingRatio: 0.6}', () {
          expect(DefaultPillJelly.frameConfig.springs.scaleX.stiffness, 250);
          expect(DefaultPillJelly.frameConfig.springs.scaleX.dampingRatio, 0.6);
        });

        test('scaleY is {stiffness: 250, dampingRatio: 0.7}', () {
          expect(DefaultPillJelly.frameConfig.springs.scaleY.stiffness, 250);
          expect(DefaultPillJelly.frameConfig.springs.scaleY.dampingRatio, 0.7);
        });

        test('value is {stiffness: 1000, dampingRatio: 1}', () {
          expect(DefaultPillJelly.frameConfig.springs.value.stiffness, 1000);
          expect(DefaultPillJelly.frameConfig.springs.value.dampingRatio, 1);
        });

        test('velocity is {stiffness: 300, dampingRatio: 0.5}', () {
          expect(
            DefaultPillJelly.frameConfig.springs.velocity.stiffness,
            300,
          );
          expect(
            DefaultPillJelly.frameConfig.springs.velocity.dampingRatio,
            0.5,
          );
        });
      });
    });
  });

  group(DefaultDistortion, () {
    test('pressedScale is 1.025', () {
      expect(DefaultDistortion.pressedScale, 1.025);
    });

    group('touchFeedback', () {
      test('middleOpacityRatio is 0.43', () {
        expect(DefaultDistortion.touchFeedback.middleOpacityRatio, 0.43);
      });

      test('opacity is 0.15', () {
        expect(DefaultDistortion.touchFeedback.opacity, 0.15);
      });

      test('radius is 150', () {
        expect(DefaultDistortion.touchFeedback.radius, 150);
      });

      test('scale is 2', () {
        expect(DefaultDistortion.touchFeedback.scale, 2);
      });
    });

    group('spring', () {
      test('damping is 18', () {
        expect(DefaultDistortion.spring.damping, 18);
      });

      test('mass is 0.9', () {
        expect(DefaultDistortion.spring.mass, 0.9);
      });

      test('stiffness is 240', () {
        expect(DefaultDistortion.spring.stiffness, 240);
      });
    });

    group('verticalDrag', () {
      test('distortion is 0.08', () {
        expect(DefaultDistortion.verticalDrag.distortion, 0.08);
      });

      test('distanceForMaxDistortion is 700', () {
        expect(
          DefaultDistortion.verticalDrag.distanceForMaxDistortion,
          700,
        );
      });

      test('follow is 0.25', () {
        expect(DefaultDistortion.verticalDrag.follow, 0.25);
      });

      test('rubberBand is 0.14', () {
        expect(DefaultDistortion.verticalDrag.rubberBand, 0.14);
      });
    });
  });
}
