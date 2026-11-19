import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';
import 'package:provider/provider.dart';

import '../logic/activity.dart';
import '../logic/beach_score.dart';
import '../logic/insights.dart';
import '../state/beach_controller.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'common.dart';
import 'ocean_background.dart';
import 'score_ring.dart';

/// The sky postcard: score, rating, verdict and the best window.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BeachController>();
    final score = c.dayScore;
    final verdict = BeachScorer.verdict(score, c.activity);
    final focus = c.focusHour;
    final window = c.bestWindow;
    final fmt = DateFormat('HH:mm');
    final passed = c.isToday && window != null && window.end.isBefore(c.beachNow);
    final sky = SkyTheme.forHour(
      c.isToday ? c.beachNow.hour : 13,
      isDay: c.isToday ? (focus?.isDay ?? true) : true,
    );
    final white70 = Colors.white.withValues(alpha: .78);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showBreakdown(context, c);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: sky.sea.last.withValues(alpha: .35), blurRadius: 30, offset: const Offset(0, 16)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: SkyScene(
            theme: sky,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RatingChip(score: score, onDark: true),
                      const Spacer(),
                      if (focus != null) ...[
                        Icon(weatherInfo(focus.weatherCode, isDay: focus.isDay).icon, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(c.units.temp(focus.airTemp),
                            style: AppText.body(15, color: Colors.white, weight: FontWeight.w700)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(child: ScoreRing(score: score, color: verdict.color)),
                  const SizedBox(height: 6),
                  Text(verdict.title, style: AppText.display(30, color: Colors.white))
                      .animate(key: ValueKey('${c.dayIndex}${c.activity}'))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: .25, curve: Curves.easeOutCubic),
                  const SizedBox(height: 6),
                  Text(
                    focus == null ? verdict.message : conditionsSummary(focus, c.units),
                    style: AppText.body(15, color: white70),
                  ),
                  const SizedBox(height: 18),
                  if (window != null)
                    Builder(builder: (_) {
                      // Today's window is over: point to tomorrow instead.
                      final next = passed ? c.windowFor(1) : null;
                      final w = next ?? window;
                      return _WindowPill(
                        label: next != null
                            ? 'Next best time · tomorrow'
                            : passed
                                ? 'Best window today (passed)'
                                : 'Best time to ${c.activity.verb}',
                        range: '${fmt.format(w.start)} – ${fmt.format(w.end)}',
                        score: w.score,
                      );
                    }),
                  const SizedBox(height: 40), // room for the waves
                  Row(
                    children: [
                      Icon(PhIcons.info, size: 14, color: white70),
                      const SizedBox(width: 6),
                      Text('Tap to see how the score is made',
                          style: AppText.body(12, color: white70)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBreakdown(BuildContext context, BeachController c) {
    final s = c.focusScore;
    if (s == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.card,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _BreakdownSheet(score: s, hour: c.focusHour!.time),
    );
  }
}

class _WindowPill extends StatelessWidget {
  const _WindowPill({required this.label, required this.range, required this.score});
  final String label, range;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(PhIcons.clockBold, size: 18, color: Palette.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.body(12, color: Colors.white.withValues(alpha: .8))),
                Text(range, style: AppText.display(20, color: Colors.white)),
              ],
            ),
          ),
          RatingChip(score: score, onDark: true),
        ],
      ),
    );
  }
}

class _BreakdownSheet extends StatelessWidget {
  const _BreakdownSheet({required this.score, required this.hour});
  final HourScore score;
  final DateTime hour;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Score at ${DateFormat('HH:00').format(hour)}', style: AppText.display(24)),
                ),
                Text('${score.score}', style: AppText.display(24, color: Palette.score(score.score))),
              ],
            ),
            if (score.penalty != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(PhIcons.warningFill, size: 16, color: Palette.coral),
                  const SizedBox(width: 6),
                  Text(score.penalty!, style: AppText.body(14, color: Palette.coral, weight: FontWeight.w700)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            for (final (i, f) in score.factors.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(f.icon, size: 18, color: Palette.sea),
                    const SizedBox(width: 10),
                    SizedBox(width: 128, child: Text(f.label, style: AppText.body(13))),
                    Expanded(
                      child: ValueBar(value: f.value, color: Palette.score((f.value * 100).round()), delay: i * 80),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text('${(f.weight * 100).round()}%',
                          textAlign: TextAlign.end, style: AppText.body(12, color: Palette.inkFaint)),
                    ),
                  ],
                ),
              ),
            Text('Bars show how good each factor is right now. The % is how much it counts for this activity.',
                style: AppText.body(12, color: Palette.inkSoft)),
          ],
        ),
      ),
    );
  }
}
