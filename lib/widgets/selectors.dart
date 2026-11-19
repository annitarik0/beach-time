import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';

import '../logic/activity.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';

/// Swim / Surf / Chill segmented control with a sliding ink pill.
class ActivitySelector extends StatelessWidget {
  const ActivitySelector({super.key, required this.value, required this.onChanged});
  final Activity value;
  final ValueChanged<Activity> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = Activity.values;
    final index = items.indexOf(value);
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Palette.sunk, borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth / items.length;
        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              left: w * index,
              top: 0,
              bottom: 0,
              width: w,
              child: Container(
                decoration: BoxDecoration(
                  color: Palette.ink,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x220F2A35), blurRadius: 10, offset: Offset(0, 4))],
                ),
              ),
            ),
            Row(
              children: [
                for (final a in items)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: a == value,
                      label: a.label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onChanged(a);
                        },
                        child: TweenAnimationBuilder<Color?>(
                          tween: ColorTween(end: a == value ? Colors.white : Palette.inkSoft),
                          duration: const Duration(milliseconds: 250),
                          builder: (_, color, __) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(a.icon, size: 18, color: color),
                              const SizedBox(width: 7),
                              Text(a.label, style: AppText.body(14, color: color!, weight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

/// Day picker: each chip shows the day, its score and a colour tick.
class DayChips extends StatelessWidget {
  const DayChips({
    super.key,
    required this.days,
    required this.scores,
    required this.selected,
    required this.bestIndex,
    required this.onSelected,
  });

  final List<DailySummary> days;
  final List<int> scores;
  final int selected;
  final int bestIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = i == selected;
          final score = i < scores.length ? scores[i] : 0;
          final fg = sel ? Colors.white : Palette.ink;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              width: 62,
              decoration: BoxDecoration(
                color: sel ? Palette.ink : Palette.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: sel ? Palette.ink : Palette.line),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        i == 0 ? 'Today' : DateFormat('EEE').format(days[i].date),
                        style: AppText.body(12, color: sel ? Colors.white70 : Palette.inkSoft, weight: FontWeight.w700),
                      ),
                      if (i == bestIndex) ...[
                        const SizedBox(width: 2),
                        const Icon(PhIcons.starFill, size: 10, color: Palette.sun),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$score', style: AppText.display(22, color: fg)),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: sel ? 26 : 18,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Palette.score(score),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
