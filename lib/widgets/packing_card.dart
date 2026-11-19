import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ph_icons.dart';

import '../logic/insights.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'common.dart';
import 'glass_card.dart';

/// Smart checklist built from the day's conditions; ticks are saved.
class PackingCard extends StatelessWidget {
  const PackingCard({
    super.key,
    required this.items,
    required this.isChecked,
    required this.onToggle,
  });

  final List<PackItem> items;
  final bool Function(String id) isChecked;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final done = items.where((i) => isChecked(i.id)).length;
    final progress = items.isEmpty ? 0.0 : done / items.length;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitle('Beach bag',
              icon: PhIcons.backpackBold,
              trailing: Text('$done of ${items.length}', style: AppText.body(13, weight: FontWeight.w800))),
          ValueBar(value: progress, color: Palette.sea, height: 6),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: progress == 1
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('All packed. Enjoy the beach.',
                        style: AppText.body(13, color: Palette.sea, weight: FontWeight.w700)),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 6),
          for (final item in items) _Row(item: item, checked: isChecked(item.id), onTap: () => onToggle(item.id)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.checked, required this.onTap});
  final PackItem item;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? Palette.sea : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: checked ? Palette.sea : Palette.inkFaint, width: 1.6),
              ),
              child: AnimatedScale(
                scale: checked ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: const Icon(PhIcons.checkBold, size: 14, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Icon(item.icon, size: 20, color: checked ? Palette.inkFaint : Palette.ink),
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: checked ? .45 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.label,
                        style: AppText.body(15, weight: FontWeight.w600).copyWith(
                          decoration: checked ? TextDecoration.lineThrough : null,
                          decorationColor: Palette.ink,
                        )),
                    if (item.reason != null)
                      Text(item.reason!, style: AppText.body(12, color: Palette.inkSoft)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
