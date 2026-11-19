import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';

import '../logic/beach_score.dart';
import '../logic/insights.dart';
import '../models/forecast.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'common.dart';
import 'glass_card.dart';

/// Hour-by-hour score bars with weather, temperature and wind arrows,
/// auto-scrolled to the focus hour.
class HourlyStrip extends StatefulWidget {
  const HourlyStrip({
    super.key,
    required this.hours,
    required this.scores,
    required this.focusIndex,
    required this.units,
  });

  final List<HourlyConditions> hours;
  final List<HourScore> scores;
  final int focusIndex;
  final Units units;

  @override
  State<HourlyStrip> createState() => _HourlyStripState();
}

class _HourlyStripState extends State<HourlyStrip> {
  static const _w = 56.0;
  late final ScrollController _scroll = ScrollController(initialScrollOffset: _offsetFor(widget.focusIndex));

  double _offsetFor(int i) => (i - 1).clamp(0, 24) * (_w + 6);

  @override
  void didUpdateWidget(HourlyStrip old) {
    super.didUpdateWidget(old);
    if (old.focusIndex != widget.focusIndex && _scroll.hasClients) {
      _scroll.animateTo(
        _offsetFor(widget.focusIndex).clamp(0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CardTitle('Hour by hour', icon: PhIcons.chartBarBold),
          ),
          SizedBox(
            height: 196,
            child: ListView.separated(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: widget.hours.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) => _HourItem(
                hour: widget.hours[i],
                score: widget.scores[i].score,
                focused: i == widget.focusIndex,
                units: widget.units,
                width: _w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourItem extends StatelessWidget {
  const _HourItem({
    required this.hour,
    required this.score,
    required this.focused,
    required this.units,
    required this.width,
  });

  final HourlyConditions hour;
  final int score;
  final bool focused;
  final Units units;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = Palette.score(score);
    final dim = !hour.isDay;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: focused ? Palette.foam : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Opacity(
        opacity: dim ? .5 : 1,
        child: Column(
          children: [
            Text(DateFormat('HH').format(hour.time),
                style: AppText.body(12, color: focused ? Palette.seaDeep : Palette.inkSoft, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Icon(weatherInfo(hour.weatherCode, isDay: hour.isDay).icon, size: 20, color: Palette.ink),
            const SizedBox(height: 6),
            Text(units.temp(hour.airTemp), style: AppText.body(14, weight: FontWeight.w700)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: 10,
                decoration: BoxDecoration(color: Palette.sunk, borderRadius: BorderRadius.circular(6)),
                alignment: Alignment.bottomCenter,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutQuart,
                  builder: (_, v, __) => FractionallySizedBox(
                    heightFactor: v.clamp(.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('$score', style: AppText.body(12, weight: FontWeight.w800)),
            const SizedBox(height: 6),
            DirectionArrow(fromDegrees: hour.windDirection, size: 12),
            Text('${hour.windSpeed.round()}', style: AppText.body(10, color: Palette.inkSoft)),
          ],
        ),
      ),
    );
  }
}
