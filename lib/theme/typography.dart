import 'package:flutter/material.dart';

import 'palette.dart';

/// Bundled variable fonts (no network, no font flash):
/// Bricolage Grotesque for headlines and numbers, Manrope for reading.
class AppText {
  static const display_ = 'Bricolage';
  static const body_ = 'Manrope';

  static List<FontFeature> get _tabular => const [FontFeature.tabularFigures()];

  /// Drive the variable font's weight axis to match [w].
  static List<FontVariation> _wght(FontWeight w, {double? opsz}) => [
        FontVariation('wght', w.value.toDouble()),
        if (opsz != null) FontVariation('opsz', opsz.clamp(12, 96)),
      ];

  static TextStyle display(double size,
          {Color color = Palette.ink, FontWeight weight = FontWeight.w700}) =>
      TextStyle(
        fontFamily: display_,
        fontSize: size,
        fontWeight: weight,
        fontVariations: _wght(weight, opsz: size),
        color: color,
        height: 1.02,
        letterSpacing: size >= 28 ? -size * .025 : -.2,
        fontFeatures: _tabular,
      );

  static TextStyle title(double size, {Color color = Palette.ink}) => TextStyle(
        fontFamily: display_,
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontVariations: _wght(FontWeight.w600, opsz: size),
        color: color,
        height: 1.2,
        letterSpacing: -.1,
      );

  static TextStyle body(double size,
          {Color color = Palette.ink, FontWeight weight = FontWeight.w500, double height = 1.45}) =>
      TextStyle(
        fontFamily: body_,
        fontSize: size,
        fontWeight: weight,
        fontVariations: _wght(weight),
        color: color,
        height: height,
        fontFeatures: _tabular,
      );

  /// Small uppercase section label.
  static TextStyle label({Color color = Palette.inkSoft}) => TextStyle(
        fontFamily: body_,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        fontVariations: _wght(FontWeight.w700),
        letterSpacing: 1.3,
        color: color,
      );
}
