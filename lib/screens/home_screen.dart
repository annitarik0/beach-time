import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/ph_icons.dart';
import 'package:provider/provider.dart';

import '../state/beach_controller.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/hero_card.dart';
import '../widgets/hourly_strip.dart';
import '../widgets/metrics_grid.dart';
import '../widgets/packing_card.dart';
import '../widgets/safety_card.dart';
import '../widgets/selectors.dart';
import '../widgets/sun_card.dart';
import '../widgets/tide_card.dart';
import '../widgets/week_card.dart';
import 'ai_chat_screen.dart';
import 'search_screen.dart';
import 'settings_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _selectDay(BeachController c, int i) {
    c.setDay(i);
    _scroll.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BeachController>();
    final f = c.forecast;
    final focus = c.focusHour;

    return Scaffold(
      backgroundColor: Palette.paper,
      floatingActionButton: f == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(fadeRoute(const AiChatScreen())),
              backgroundColor: Palette.ink,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              icon: const Icon(PhIcons.sparkleFill, color: Palette.sun),
              label: Text('Ask Beach Buddy', style: AppText.body(14, color: Colors.white, weight: FontWeight.w700)),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: .4, curve: Curves.easeOutCubic),
      body: SafeArea(
        bottom: false,
        child: f == null
            ? (c.error != null ? _ErrorView(message: c.error!, onRetry: c.refresh) : const _LoadingView())
            : RefreshIndicator(
                onRefresh: c.refresh,
                color: Palette.sea,
                backgroundColor: Palette.card,
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverToBoxAdapter(child: _Header(controller: c)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                        child: ActivitySelector(value: c.activity, onChanged: c.setActivity),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: DayChips(
                        days: f.daily,
                        scores: c.weekScores,
                        selected: c.dayIndex,
                        bestIndex: c.bestDayIndex,
                        onSelected: (i) => _selectDay(c, i),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                      sliver: SliverList.list(
                        children: _stagger([
                          const HeroCard(),
                          if (focus != null) MetricsGrid(hour: focus, units: c.units, isNow: c.isToday, now: c.beachNow),
                          if (c.dayHours.isNotEmpty)
                            HourlyStrip(
                              key: ValueKey('hours-${c.dayIndex}'),
                              hours: c.dayHours,
                              scores: c.dayScores,
                              focusIndex: c.focusIndex,
                              units: c.units,
                            ),
                          if (f.hasSeaData) TideCard(hours: c.dayHours, now: c.isToday ? c.beachNow : null, units: c.units),
                          if (c.day != null) SunCard(day: c.day!, now: c.isToday ? c.beachNow : null),
                          if (focus != null) SafetyCard(hour: focus),
                          PackingCard(items: c.packing, isChecked: c.isChecked, onToggle: c.toggleCheck),
                          WeekCard(
                            days: f.daily,
                            scores: c.weekScores,
                            selected: c.dayIndex,
                            bestIndex: c.bestDayIndex,
                            units: c.units,
                            onSelected: (i) => _selectDay(c, i),
                          ),
                          _Footer(updated: f.fetchedAt),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Cards rise in one after another, quickly and subtly.
  List<Widget> _stagger(List<Widget> items) => [
        for (final (i, w) in items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: w
                .animate(delay: (60 * i).ms)
                .fadeIn(duration: 420.ms)
                .slideY(begin: .06, curve: Curves.easeOutCubic),
          ),
      ];
}

/// Fade + slight rise page transition used across the app.
PageRouteBuilder<void> fadeRoute(Widget page) => PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final BeachController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(fadeRoute(const SearchScreen())),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE d MMMM').format(c.day?.date ?? DateTime.now()).toUpperCase(),
                    style: AppText.label(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(c.beach.name, overflow: TextOverflow.ellipsis, style: AppText.display(30)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(PhIcons.caretDownBold, size: 18, color: Palette.inkSoft),
                    ],
                  ),
                  if (c.beach.subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(PhIcons.mapPinFill, size: 13, color: Palette.coral),
                          const SizedBox(width: 4),
                          Text(c.beach.subtitle, style: AppText.body(13, color: Palette.inkSoft)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          _RoundButton(
            icon: PhIcons.arrowClockwise,
            tooltip: 'Refresh',
            busy: c.loading,
            onTap: c.refresh,
          ),
          const SizedBox(width: 8),
          _RoundButton(
            icon: PhIcons.slidersHorizontal,
            tooltip: 'Settings',
            onTap: () => showSettingsSheet(context),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap, this.busy = false});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Palette.card,
        shape: const CircleBorder(side: BorderSide(color: Palette.line)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: busy ? null : onTap,
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: busy
                  ? const SizedBox.square(
                      dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Palette.sea))
                  : Icon(icon, size: 20, color: Palette.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.updated});
  final DateTime updated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Text('Updated ${DateFormat('HH:mm').format(updated)} · Data by Open-Meteo.com (CC BY 4.0)',
              textAlign: TextAlign.center, style: AppText.body(11, color: Palette.inkFaint)),
          const SizedBox(height: 2),
          Text('Forecasts are estimates. Always follow lifeguards and local flags.',
              textAlign: TextAlign.center, style: AppText.body(11, color: Palette.inkFaint)),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    Widget block(double h, {double r = 24}) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: h,
            decoration: BoxDecoration(color: Palette.sunk, borderRadius: BorderRadius.circular(r)),
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('READING THE OCEAN', style: AppText.label()),
          const SizedBox(height: 8),
          Container(width: 200, height: 30, decoration: BoxDecoration(color: Palette.sunk, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 20),
          block(48, r: 16),
          block(84, r: 18),
          block(420, r: 32),
          block(120),
        ],
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1300.ms, color: Palette.card),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: Palette.foam, shape: BoxShape.circle),
                child: const Icon(PhIcons.cloudSlash, size: 30, color: Palette.sea),
              ),
              const SizedBox(height: 16),
              Text('Lost the signal', style: AppText.display(24)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: AppText.body(14, color: Palette.inkSoft)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.ink,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(PhIcons.arrowClockwiseBold, size: 18),
                label: Text('Try again', style: AppText.body(14, color: Colors.white, weight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(fadeRoute(const SearchScreen())),
                child: Text('Choose another beach', style: AppText.body(14, color: Palette.sea, weight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
