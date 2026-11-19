import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/palette.dart';
import '../theme/typography.dart';

/// Solid paper card with a hairline border and soft shadow.
/// Presses scale down slightly for tactile feedback.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.radius = 24,
    this.color = Palette.card,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;
  final Color color;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap != null && v != _down) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final card = AnimatedScale(
      scale: _down ? .98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: Palette.line),
          boxShadow: Palette.softShadow,
        ),
        child: widget.child,
      ),
    );
    if (widget.onTap == null) return card;
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: card,
    );
  }
}

/// Section label at the top of a card.
class CardTitle extends StatelessWidget {
  const CardTitle(this.text, {super.key, this.icon, this.trailing});
  final String text;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Palette.sea),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(text.toUpperCase(), style: AppText.label())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
