import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';

import '../logic/insights.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'common.dart';
import 'glass_card.dart';

/// Week list with Apple-Weather-style temperature range bars plus the
/// beach score per day.
class WeekCard extends StatelessWidget {
  const WeekCard({
    super.key,
    required this.days,
    required this.scores,
    required this.selected,
    required this.bestIndex,
    required this.units,
    required this.onSelected,
  });

  final List<DailySummary> days;
  final List<int> scores;
  final int selected;
  final int bestIndex;
  final Units units;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final lo = days.map((d) => d.tempMin).reduce((a, b) => a < b ? a : b);
    final hi = days.map((d) => d.tempMax).reduce((a, b) => a > b ? a : b);
    final span = (hi - lo).abs() < 1 ? 1.0 : hi - lo;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CardTitle('7-day outlook', icon: PhIcons.calendarBlankBold),
          ),
          for (var i = 0; i < days.length; i++)
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
                decoration: BoxDecoration(
                  color: i == selected ? Palette.foam : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(i == 0 ? 'Today' : DateFormat('EEE').format(days[i].date),
                          style: AppText.body(14, weight: FontWeight.w700)),
                    ),
                    Icon(weatherInfo(days[i].weatherCode).icon, size: 20, color: Palette.ink),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 30,
                      child: Text(units.temp(days[i].tempMin),
                          textAlign: TextAlign.end, style: AppText.body(13, color: Palette.inkSoft)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _RangeBar(start: (days[i].tempMin - lo) / span, end: (days[i].tempMax - lo) / span)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text(units.temp(days[i].tempMax), style: AppText.body(13, weight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 40,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Palette.score(scores[i]).withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (i == bestIndex) ...[
                            const Icon(PhIcons.starFill, size: 10, color: Palette.sun),
                            const SizedBox(width: 2),
                          ],
                          Text('${scores[i]}', style: AppText.body(13, weight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(PhIcons.starFill, size: 12, color: Palette.sun),
                const SizedBox(width: 6),
                Text('Best beach day this week', style: AppText.body(12, color: Palette.inkSoft)),
                const Spacer(),
                RatingChip(score: scores[bestIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.start, required this.end});
  final double start, end;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return Container(
        height: 6,
        decoration: BoxDecoration(color: Palette.sunk, borderRadius: BorderRadius.circular(3)),
        child: Stack(
          children: [
            Positioned(
              left: w * start,
              width: (w * (end - start)).clamp(6, w),
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(colors: [Palette.sea, Palette.sun]),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
