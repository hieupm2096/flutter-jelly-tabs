import 'package:flutter/material.dart';
import 'package:jelly_tabs/src/widgets/pill_path_clipper.dart';

/// The selected-content layer clipped to the jelly pill's capsule, replacing
/// the native masked view (see `architecture.md` §3.2).
///
/// Wraps [child] in a [ClipPath] driven by [PillPathClipper], which folds the
/// mask translate/scale into a single path. When [visible] is false the
/// widget collapses to nothing, matching the reference's hidden mask overscan
/// layer.
class PillMaskedView extends StatelessWidget {
  /// Creates a [PillMaskedView].
  const PillMaskedView({
    required this.child,
    required this.translationX,
    required this.scaleX,
    required this.scaleY,
    required this.tabWidth,
    required this.itemHeight,
    required this.left,
    required this.top,
    super.key,
    this.visible = true,
  });

  /// The selected-content layer shown inside the pill.
  final Widget child;

  /// Animated pill position, `value * tabWidth`.
  final double translationX;

  /// Velocity-shear corrected horizontal scale.
  final double scaleX;

  /// Velocity-shear corrected vertical scale.
  final double scaleY;

  /// Width of one tab; the pill's base width.
  final double tabWidth;

  /// Height of one tab; the pill's base height and capsule diameter.
  final double itemHeight;

  /// Horizontal inset of the content layer (`maskOverscanX + trackInset`).
  final double left;

  /// Vertical inset of the content layer (`maskOverscanY + trackInset`).
  final double top;

  /// Whether the pill is shown; when false, nothing is rendered.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return ClipPath(
      clipper: PillPathClipper(
        translationX: translationX,
        scaleX: scaleX,
        scaleY: scaleY,
        tabWidth: tabWidth,
        itemHeight: itemHeight,
        left: left,
        top: top,
      ),
      child: child,
    );
  }
}
