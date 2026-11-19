import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/ph_icons.dart';

import 'package:provider/provider.dart';

import '../logic/activity.dart';
import '../services/ai_service.dart';
import '../state/beach_controller.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';
import 'settings_sheet.dart';

/// Chat with an open-source LLM that sees the live forecast.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final List<AiMessage> _messages = [];
  final Set<int> _offline = {}; // indexes of answers made without the AI
  bool _thinking = false;
  String? _error;

  List<(IconData, String)> _suggestions(Activity a) => [
    (PhIcons.calendarCheck, 'Plan my perfect beach day'),
    (PhIcons.clock, 'When is the safest time to ${a.verb}?'),
    (PhIcons.baby, 'Is it OK for kids today?'),
    (PhIcons.star, 'Which day this week is best?'),
    (PhIcons.bowlFood, 'What should I bring to eat and drink?'),
  ];

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    if (q.isEmpty || _thinking) return;
    _text.clear();
    setState(() {
      _messages.add(AiMessage('user', q));
      _thinking = true;
      _error = null;
    });
    _toBottom();
    try {
      final reply = await context.read<BeachController>().askAi(_messages);
      if (mounted) {
        setState(() {
          if (reply.offline) _offline.add(_messages.length);
          _messages.add(AiMessage('assistant', reply.text));
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _thinking = false);
      _toBottom();
    }
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<BeachController>();
    return Scaffold(
      backgroundColor: Palette.paper,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(PhIcons.arrowLeft, color: Palette.ink),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Palette.ink, shape: BoxShape.circle),
                    child: const Icon(PhIcons.sparkleFill, size: 20, color: Palette.sun),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beach Buddy', style: AppText.title(18)),
                        Text(
                          '${c.aiConfig.isFree ? 'Free open-source AI' : c.aiConfig.model} · reading ${c.beach.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12, color: Palette.inkSoft),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => showSettingsSheet(context),
                    icon: const Icon(PhIcons.slidersHorizontal, color: Palette.ink),
                    tooltip: 'AI settings',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Palette.line),
            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  _Bubble(
                    text:
                        'Hi, I\'m Beach Buddy. I\'m reading the live forecast for ${c.beach.name}. '
                        'Ask me anything, like the safest time to swim or what to bring.',
                    mine: false,
                  ),
                  if (_messages.isEmpty) ...[
                    const SizedBox(height: 12),
                    for (final (i, s) in _suggestions(c.activity).indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Palette.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Palette.line),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _send(s.$2),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(s.$1, size: 18, color: Palette.sea),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(s.$2, style: AppText.body(14, weight: FontWeight.w600)),
                                  ),
                                  const Icon(PhIcons.arrowUpRight, size: 16, color: Palette.inkFaint),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate(delay: (50 * i).ms).fadeIn(duration: 300.ms).slideY(begin: .2),
                  ],
                  for (final (i, m) in _messages.indexed)
                    _Bubble(text: m.content, mine: m.role == 'user', offline: _offline.contains(i)),
                  if (_thinking) const _Typing(),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Palette.coral.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Palette.coral.withValues(alpha: .3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(PhIcons.warningCircleFill, size: 18, color: Palette.coral),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: AppText.body(14))),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: Palette.paper,
                border: Border(top: BorderSide(color: Palette.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      onSubmitted: _send,
                      textInputAction: TextInputAction.send,
                      style: AppText.body(15),
                      cursorColor: Palette.sea,
                      decoration: InputDecoration(
                        hintText: 'Ask about the beach...',
                        hintStyle: AppText.body(15, color: Palette.inkFaint),
                        filled: true,
                        fillColor: Palette.card,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Palette.line),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Palette.sea),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _thinking ? null : () => _send(_text.text),
                    style: IconButton.styleFrom(backgroundColor: Palette.ink, minimumSize: const Size(50, 50)),
                    icon: const Icon(PhIcons.paperPlaneRightFill, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine, this.offline = false});
  final String text;
  final bool mine;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .8),
            decoration: BoxDecoration(
              color: mine ? Palette.ink : Palette.card,
              border: mine ? null : Border.all(color: Palette.line),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(mine ? 20 : 6),
                bottomRight: Radius.circular(mine ? 6 : 20),
              ),
            ),
            child: SelectableText(
              text.replaceAll('**', ''),
              style: AppText.body(15, color: mine ? Colors.white : Palette.ink),
            ),
          ),
          if (offline)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(PhIcons.info, size: 12, color: Palette.inkFaint),
                  const SizedBox(width: 4),
                  Text('Quick answer from the forecast', style: AppText.body(11, color: Palette.inkFaint)),
                ],
              ),
            ),
        ],
      ).animate().fadeIn(duration: 250.ms).slideY(begin: .15, curve: Curves.easeOutCubic),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Palette.card,
        border: Border.all(color: Palette.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(color: Palette.sea, shape: BoxShape.circle),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true), delay: (140 * i).ms)
                .fade(begin: .3, end: 1, duration: 450.ms)
                .moveY(begin: 0, end: -4, duration: 450.ms, curve: Curves.easeInOut),
        ],
      ),
    ),
  );
}
