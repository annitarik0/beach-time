import 'package:flutter/material.dart';

/// Coastal editorial palette: warm sand paper, deep-sea ink, one sea accent,
/// coral and sun used sparingly.
class Palette {
  // Surfaces
  static const paper = Color(0xFFF4EEE4);
  static const card = Color(0xFFFFFCF7);
  static const line = Color(0xFFE6DCCD);
  static const sunk = Color(0xFFEDE5D8); // inset tracks, chips

  // Ink
  static const ink = Color(0xFF0F2A35);
  static const inkSoft = Color(0xFF52707B);
  static const inkFaint = Color(0xFF8FA3AA);

  // Accents
  static const sea = Color(0xFF127C8A);
  static const seaDeep = Color(0xFF0B4F5C);
  static const foam = Color(0xFFD7ECEA);
  static const coral = Color(0xFFE8623F);
  static const sun = Color(0xFFF2B33D);
  static const kelp = Color(0xFF4A9B76);

  static Color white(double a) => Colors.white.withValues(alpha: a);
  static Color inkA(double a) => ink.withValues(alpha: a);

  /// One cohesive ramp for every score in the app.
  static Color score(int s) {
    if (s >= 85) return sea;
    if (s >= 70) return kelp;
    if (s >= 55) return sun;
    if (s >= 40) return const Color(0xFFEA8A3A);
    return coral;
  }

  static const softShadow = [
    BoxShadow(color: Color(0x0F0F2A35), blurRadius: 24, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x080F2A35), blurRadius: 4, offset: Offset(0, 1)),
  ];
}

/// Sky + sea colours for the hero postcard, following the beach's local time.
class SkyTheme {
  const SkyTheme(this.sky, this.sea, this.sunColor, this.isNight);
  final List<Color> sky;
  final List<Color> sea; // back → front wave layers
  final Color sunColor;
  final bool isNight;

  static SkyTheme forHour(int hour, {required bool isDay}) {
    if (!isDay) {
      return const SkyTheme(
        [Color(0xFF0C1B2E), Color(0xFF172C47), Color(0xFF2A4766)],
        [Color(0xFF1E3B57), Color(0xFF15304A), Color(0xFF0E2438)],
        Color(0xFFF3EEDC),
        true,
      );
    }
    if (hour < 9) {
      return const SkyTheme(
        [Color(0xFF3B4A7A), Color(0xFFA9677E), Color(0xFFF0A97F)],
        [Color(0xFF6C7FA0), Color(0xFF3F5E86), Color(0xFF26456B)],
        Color(0xFFFFD9A0),
        false,
      );
    }
    if (hour >= 17) {
      return const SkyTheme(
        [Color(0xFF23365F), Color(0xFFB9566A), Color(0xFFF2A45E)],
        [Color(0xFF7A5D7E), Color(0xFF3D4F78), Color(0xFF213A60)],
        Color(0xFFFFC773),
        false,
      );
    }
    return const SkyTheme(
      [Color(0xFF17768F), Color(0xFF3FA0B6), Color(0xFF9CD1D3)],
      [Color(0xFF4FAAB4), Color(0xFF1E8796), Color(0xFF0D6474)],
      Color(0xFFFFE2A1),
      false,
    );
  }
}
