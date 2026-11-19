import 'package:intl/intl.dart';

import '../state/beach_controller.dart';
import 'activity.dart';
import 'beach_score.dart';
import 'insights.dart';

/// Answers common questions straight from the forecast, with no network.
/// Used when the free AI is busy or unreachable, so Beach Buddy always replies.
String offlineAnswer(String question, BeachController c) {
  final q = question.toLowerCase();
  final f = c.forecast;
  final d = c.day;
  final h = c.focusHour;
  if (f == null || d == null || h == null) {
    return 'I need the forecast first. Pull down on the home screen to refresh, then ask me again.';
  }
  bool has(List<String> words) => words.any(q.contains);

  final fmt = DateFormat('HH:mm');
  final u = c.units;
  final w = c.bestWindow;
  final when = c.isToday ? 'today' : 'on ${DateFormat('EEEE').format(d.date)}';
  final window = w == null
      ? 'There is no good window in daylight $when.'
      : 'The best time to ${c.activity.verb} $when is ${fmt.format(w.start)} to ${fmt.format(w.end)} '
            '(${BeachScorer.rating(w.score).toLowerCase()}, ${w.score}/100).';
  final safety = safetyFor(h);
  final sun = sunAdvice(d.uvMax);
  final water = h.waterTemp == null ? '' : ' The water is about ${u.temp(h.waterTemp!)}.';

  if (has(['week', 'which day', 'best day', 'tomorrow', 'weekend'])) {
    final best = c.bestDayIndex;
    final name = best == 0 ? 'today' : DateFormat('EEEE').format(f.daily[best].date);
    final tw = c.windowFor(best);
    return 'The best day this week is $name with ${c.weekScores[best]}/100'
        '${tw == null ? '' : ', best between ${fmt.format(tw.start)} and ${fmt.format(tw.end)}'}. '
        'Tap the days at the top to compare them.';
  }
  if (has(['kid', 'child', 'baby', 'family', 'toddler'])) {
    final ok = safety.flag == FlagLevel.green;
    return '${ok ? 'Yes, it looks calm enough for kids.' : 'Be careful with kids: ${safety.headline.toLowerCase()}.'} '
        '${safety.flagLabel}, rip current risk ${safety.ripRisk.toLowerCase()}, '
        'waves around ${u.height(h.waveHeight ?? 0)}.$water '
        'Stay close, use a lifeguarded spot and reapply ${sun.spf} every two hours. $window';
  }
  if (has(['eat', 'drink', 'food', 'bring', 'pack', 'bag', 'snack'])) {
    final items = c.packing.take(6).map((p) => p.label.toLowerCase()).join(', ');
    return 'Bring $items. Pack fruit like watermelon or grapes, salty snacks and more water than you think: '
        'about ${h.airTemp >= 30
            ? 3
            : h.airTemp >= 24
            ? 2
            : 1} litres per person. $window';
  }
  if (has(['uv', 'sun', 'burn', 'spf', 'cream'])) {
    return 'UV peaks at ${d.uvMax.round()} (${sun.level.toLowerCase()}). Use ${sun.spf}'
        '${sun.burnMinutes == null ? '' : ', fair skin can burn in about ${sun.burnMinutes} minutes'}. '
        '${sun.tip} Sunset is at ${fmt.format(d.sunset)}.';
  }
  if (has(['tide', 'high water', 'low water'])) {
    final t = tideEvents(c.dayHours);
    if (t.isEmpty) return 'I have no tide data for this beach.';
    return 'Tides $when: ${t.map((e) => '${e.isHigh ? 'high' : 'low'} at ${fmt.format(e.time)}').join(', ')}.';
  }
  if (has(['safe', 'danger', 'rip', 'current', 'flag', 'jellyfish'])) {
    return '${safety.headline} ${safety.flagLabel}, rip current risk ${safety.ripRisk.toLowerCase()}. '
        '${safety.notes.take(2).join(' ')} $window Always follow the lifeguards and local flags.';
  }
  if (has(['surf', 'wave', 'swell', 'wind'])) {
    return 'Waves around ${u.height(h.waveHeight ?? 0)}'
        '${h.wavePeriod == null ? '' : ' every ${h.wavePeriod!.round()} s'}, '
        'wind ${u.wind(h.windSpeed)} from the ${compass(h.windDirection)}, gusts ${u.wind(h.windGusts)}. '
        '${c.activity == Activity.surf ? window : 'For surfing, switch to Surf at the top to see its best time.'}';
  }
  // Plan, best time and anything else: a short day plan.
  return '${conditionsSummary(h, u)} $window '
      '${safety.flagLabel}, rip current risk ${safety.ripRisk.toLowerCase()}.$water '
      'Use ${sun.spf}, sunset is at ${fmt.format(d.sunset)}.';
}
