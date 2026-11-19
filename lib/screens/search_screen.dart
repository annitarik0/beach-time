import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/ph_icons.dart';
import 'package:provider/provider.dart';

import '../data/popular_beaches.dart';
import '../models/beach.dart';
import '../state/beach_controller.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import '../widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _text = TextEditingController();
  Timer? _debounce;
  List<Beach> _results = [];
  bool _searching = false;
  bool _locating = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(q));
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final r = await context.read<BeachController>().api.searchPlaces(q);
      if (mounted && _text.text == q) setState(() => _results = r);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pick(Beach b) {
    final c = context.read<BeachController>();
    Navigator.of(context).pop();
    c.selectBeach(b);
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    final c = context.read<BeachController>();
    try {
      await c.useMyLocation();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BeachController>();
    final showResults = _text.text.trim().length >= 2;

    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(PhIcons.arrowLeft, color: Palette.ink),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text('Where to?', style: AppText.display(34)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _text,
                autofocus: true,
                onChanged: _onChanged,
                style: AppText.body(16, weight: FontWeight.w600),
                cursorColor: Palette.sea,
                decoration: InputDecoration(
                  hintText: 'Search any beach, town or city',
                  hintStyle: AppText.body(16, color: Palette.inkFaint),
                  prefixIcon: const Icon(PhIcons.magnifyingGlass, color: Palette.inkSoft),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Palette.sea)),
                        )
                      : null,
                  filled: true,
                  fillColor: Palette.card,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Palette.line)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Palette.sea, width: 1.5)),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: Text(_error!, style: AppText.body(13, color: Palette.coral, weight: FontWeight.w600)),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  _Tile(
                    icon: PhIcons.crosshairFill,
                    iconColor: Palette.sea,
                    title: 'Use my current location',
                    busy: _locating,
                    onTap: _locate,
                  ),
                  const SizedBox(height: 24),
                  if (showResults) ...[
                    _Section('Results'),
                    if (_results.isEmpty && !_searching)
                      Text('No places found. Try a nearby town.', style: AppText.body(14, color: Palette.inkSoft)),
                    for (final (i, b) in _results.indexed)
                      _Tile(icon: PhIcons.mapPin, title: b.name, subtitle: b.subtitle, onTap: () => _pick(b))
                          .animate(delay: (30 * i).ms)
                          .fadeIn(duration: 250.ms)
                          .slideY(begin: .1),
                  ] else ...[
                    if (c.savedBeaches.isNotEmpty) ...[
                      _Section('Saved'),
                      for (final b in c.savedBeaches)
                        Dismissible(
                          key: ValueKey(b.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => c.removeBeach(b),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(PhIcons.trash, color: Palette.coral),
                          ),
                          child: _Tile(
                            icon: b == c.beach ? PhIcons.checkCircleFill : PhIcons.mapPin,
                            iconColor: b == c.beach ? Palette.sea : null,
                            title: b.name,
                            subtitle: b.subtitle,
                            onTap: () => _pick(b),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                    _Section('Popular beaches'),
                    for (final (i, b) in popularBeaches.indexed)
                      _Tile(icon: PhIcons.sunHorizon, title: b.name, subtitle: b.subtitle, onTap: () => _pick(b))
                          .animate(delay: (25 * i).ms)
                          .fadeIn(duration: 250.ms),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 10, left: 4), child: Text(text.toUpperCase(), style: AppText.label()));
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.busy = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: busy ? null : onTap,
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            busy
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Palette.sea))
                : Icon(icon, size: 20, color: iconColor ?? Palette.inkSoft),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.body(15, weight: FontWeight.w700)),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!, style: AppText.body(13, color: Palette.inkSoft)),
                ],
              ),
            ),
            const Icon(PhIcons.caretRight, size: 16, color: Palette.inkFaint),
          ],
        ),
      ),
    );
  }
}
