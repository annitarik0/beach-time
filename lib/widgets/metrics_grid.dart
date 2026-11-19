import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';

import '../logic/insights.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'common.dart';
import 'glass_card.dart';

/// Six key numbers for the focus hour.
class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key, required this.hour, required this.units, required this.isNow, this.now});
  final HourlyConditions hour;
  final Units units;
  final bool isNow;
  final DateTime? now; // beach-local time

  @override
  Widget build(BuildContext context) {
    final h = hour;
    final tiles = <_Metric>[
      _Metric(PhIcons.thermometerSimple, 'Air', units.temp(h.airTemp), 'Feels ${units.temp(h.feelsLike)}'),
      _Metric(PhIcons.drop, 'Water', h.waterTemp == null ? '–' : units.temp(h.waterTemp!),
          h.waterTemp == null ? 'No sea data' : _waterFeel(h.waterTemp!)),
      _Metric(PhIcons.wind, 'Wind', units.wind(h.windSpeed),
          '${compass(h.windDirection)} · gusts ${units.wind(h.windGusts)}',
          direction: h.windDirection),
      _Metric(PhIcons.waves, 'Waves', h.waveHeight == null ? '–' : units.height(h.waveHeight!),
          h.wavePeriod == null ? 'No sea data' : '${h.wavePeriod!.round()} s period',
          direction: h.waveDirection),
      _Metric(PhIcons.sun, 'UV index', h.uvIndex.toStringAsFixed(0), sunAdvice(h.uvIndex).level),
      _Metric(PhIcons.umbrella, 'Rain', '${h.rainChance}%', '${h.cloudCover}% cloud cover'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            isNow && now != null
                ? 'CONDITIONS NOW · ${DateFormat('HH:mm').format(now!)} LOCAL'
                : 'CONDITIONS AT ${DateFormat('HH:00').format(h.time)}',
            style: AppText.label(),
          ),
        ),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 560 ? 3 : 2;
          final w = (c.maxWidth - (cols - 1) * 10) / cols;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final (i, t) in tiles.indexed)
                SizedBox(
                  width: w,
                  child: AppCard(
                    radius: 20,
                    padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(t.icon, size: 16, color: Palette.sea),
                            const SizedBox(width: 6),
                            Expanded(child: Text(t.label, style: AppText.body(13, color: Palette.inkSoft, weight: FontWeight.w600))),
                            if (t.direction != null) DirectionArrow(fromDegrees: t.direction!, color: Palette.sea),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(t.value, style: AppText.display(28)),
                        ),
                        const SizedBox(height: 4),
                        Text(t.sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.body(12, color: Palette.inkSoft)),
                      ],
                    ),
                  ).animate(delay: (40 * i).ms).fadeIn(duration: 350.ms).slideY(begin: .08, curve: Curves.easeOutCubic),
                ),
            ],
          );
        }),
      ],
    );
  }

  static String _waterFeel(double t) => t >= 26
      ? 'Bath-warm'
      : t >= 22
          ? 'Pleasant'
          : t >= 18
              ? 'Refreshing'
              : 'Cold, wetsuit advised';
}

class _Metric {
  const _Metric(this.icon, this.label, this.value, this.sub, {this.direction});
  final IconData icon;
  final String label, value, sub;
  final int? direction;
}
