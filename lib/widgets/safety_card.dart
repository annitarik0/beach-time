import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ph_icons.dart';

import '../logic/insights.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'glass_card.dart';

class SafetyCard extends StatelessWidget {
  const SafetyCard({super.key, required this.hour});
  final HourlyConditions hour;

  @override
  Widget build(BuildContext context) {
    final s = safetyFor(hour);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardTitle('Water safety', icon: PhIcons.lifebuoyBold),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: s.color.withValues(alpha: .14), borderRadius: BorderRadius.circular(16)),
                child: Icon(PhIcons.flagPennantFill, size: 28, color: s.color)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(begin: -.015, end: .015, duration: 1200.ms, curve: Curves.easeInOut, alignment: Alignment.bottomLeft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.headline, style: AppText.title(17)),
                    const SizedBox(height: 2),
                    Text('${s.flagLabel} (estimated)', style: AppText.body(13, color: Palette.inkSoft)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Pill(label: 'Rip risk', value: s.ripRisk),
              const SizedBox(width: 8),
              if (hour.aqi != null) _Pill(label: 'Air', value: '${aqiLabel(hour.aqi!)} · ${hour.aqi}'),
            ],
          ),
          const SizedBox(height: 14),
          for (final n in s.notes)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(PhIcons.info, size: 14, color: Palette.inkFaint),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(n, style: AppText.body(13, color: Palette.inkSoft))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Palette.sunk, borderRadius: BorderRadius.circular(12)),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '$label  ', style: AppText.body(12, color: Palette.inkSoft)),
              TextSpan(text: value, style: AppText.body(12, weight: FontWeight.w800)),
            ]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
}
