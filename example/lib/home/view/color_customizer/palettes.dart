import 'package:jelly_tabs/jelly_tabs.dart';

/// Track and pill backdrop blur intensities (on `expo-blur`'s 1-100 scale).
class BlurConfig {
  const BlurConfig({required this.pill, required this.track});

  final double pill;
  final double track;
}

/// Default look — the same "Amber" preset the reference example starts with.
const kInitialColors = JellyTabsColors(
  activeContent: Color(0xFF451A03),
  inactiveContent: Color(0xFFA8A29E),
  selectedSurface: Color(0xFFF59E0B),
  surface: Color(0xFF1C1917),
);

/// Default backdrop blur intensities, matching the reference example.
const kInitialBlur = BlurConfig(pill: 20, track: 35);

/// Opacity applied whenever a preset is picked (and used as the default look).
/// Values are the reference demo opacities bumped ~30% toward fully opaque.
const kThemeOpacity = JellyTabsOpacity(
  activeContent: 1,
  inactiveContent: 1,
  selectedSurface: 1,
  surface: 0.78,
);

/// A named color preset, mirroring the reference's `PALETTES`.
class PalettePreset {
  const PalettePreset({
    required this.label,
    required this.activeContent,
    required this.inactiveContent,
    required this.selectedSurface,
    required this.surface,
  });

  final String label;
  final Color activeContent;
  final Color inactiveContent;
  final Color selectedSurface;
  final Color surface;

  JellyTabsColors get colors => JellyTabsColors(
    activeContent: activeContent,
    inactiveContent: inactiveContent,
    selectedSurface: selectedSurface,
    surface: surface,
  );
}

/// The 12 presets exposed in the Palette panel, ported verbatim from the
/// reference example.
const kPalettes = <PalettePreset>[
  PalettePreset(
    label: 'Blue',
    activeContent: Color(0xFFEFF6FF),
    inactiveContent: Color(0xFFA1A1AA),
    selectedSurface: Color(0xFF2563EB),
    surface: Color(0xFF18181B),
  ),
  PalettePreset(
    label: 'Indigo',
    activeContent: Color(0xFFEEF2FF),
    inactiveContent: Color(0xFFA5B4FC),
    selectedSurface: Color(0xFF4F46E5),
    surface: Color(0xFF1E1B4B),
  ),
  PalettePreset(
    label: 'Violet',
    activeContent: Color(0xFFF5F3FF),
    inactiveContent: Color(0xFFA1A1AA),
    selectedSurface: Color(0xFF7C3AED),
    surface: Color(0xFF18181B),
  ),
  PalettePreset(
    label: 'Pink',
    activeContent: Color(0xFFFDF2F8),
    inactiveContent: Color(0xFFA1A1AA),
    selectedSurface: Color(0xFFEC4899),
    surface: Color(0xFF18181B),
  ),
  PalettePreset(
    label: 'Rose',
    activeContent: Color(0xFFFFF1F2),
    inactiveContent: Color(0xFFA1A1AA),
    selectedSurface: Color(0xFFE11D48),
    surface: Color(0xFF18181B),
  ),
  PalettePreset(
    label: 'Red',
    activeContent: Color(0xFFFEF2F2),
    inactiveContent: Color(0xFFA1A1AA),
    selectedSurface: Color(0xFFDC2626),
    surface: Color(0xFF18181B),
  ),
  PalettePreset(
    label: 'Orange',
    activeContent: Color(0xFFFFF7ED),
    inactiveContent: Color(0xFFA8A29E),
    selectedSurface: Color(0xFFEA580C),
    surface: Color(0xFF1C1917),
  ),
  PalettePreset(
    label: 'Amber',
    activeContent: Color(0xFF451A03),
    inactiveContent: Color(0xFFA8A29E),
    selectedSurface: Color(0xFFF59E0B),
    surface: Color(0xFF1C1917),
  ),
  PalettePreset(
    label: 'Emerald',
    activeContent: Color(0xFFECFDF5),
    inactiveContent: Color(0xFFA1A1AA),
    selectedSurface: Color(0xFF10B981),
    surface: Color(0xFF18181B),
  ),
  PalettePreset(
    label: 'Teal',
    activeContent: Color(0xFFF0FDFA),
    inactiveContent: Color(0xFF94A3B8),
    selectedSurface: Color(0xFF14B8A6),
    surface: Color(0xFF0F172A),
  ),
  PalettePreset(
    label: 'Cyan',
    activeContent: Color(0xFFECFEFF),
    inactiveContent: Color(0xFF94A3B8),
    selectedSurface: Color(0xFF06B6D4),
    surface: Color(0xFF0F172A),
  ),
  PalettePreset(
    label: 'Mono',
    activeContent: Color(0xFF171717),
    inactiveContent: Color(0xFFA3A3A3),
    selectedSurface: Color(0xFFFAFAFA),
    surface: Color(0xFF171717),
  ),
];

/// Converts a [Color] to a `#RRGGBB` hex string.
String toHex(Color color) {
  final argb = color.toARGB32();
  final rgb = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  return '#${rgb.toUpperCase()}';
}

/// Parses a `#RRGGBB` (or `RRGGBB`) hex string into a [Color].
Color colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(0xFF000000 | int.parse(normalized, radix: 16));
}
