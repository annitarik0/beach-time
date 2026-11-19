import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ai_service.dart';
import '../state/beach_controller.dart';
import '../theme/palette.dart';
import '../theme/typography.dart';

Future<void> showSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Palette.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<BeachController>(),
        child: const _SettingsSheet(),
      ),
    );

class _SettingsSheet extends StatefulWidget {
  const _SettingsSheet();

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late final BeachController c = context.read<BeachController>();
  late final _url = TextEditingController(text: c.aiConfig.baseUrl);
  late final _model = TextEditingController(text: c.aiConfig.model);
  late final _key = TextEditingController(text: c.aiConfig.apiKey);
  bool _hideKey = true;

  @override
  void dispose() {
    _url.dispose();
    _model.dispose();
    _key.dispose();
    super.dispose();
  }

  void _save() {
    c.setAiConfig(AiConfig(baseUrl: _url.text.trim(), model: _model.text.trim(), apiKey: _key.text.trim()));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final imperial = context.watch<BeachController>().imperial;
    InputDecoration deco(String label, {Widget? suffix}) => InputDecoration(
          labelText: label,
          labelStyle: AppText.body(14, color: Palette.inkSoft),
          suffixIcon: suffix,
          filled: true,
          fillColor: Palette.paper,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Palette.line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Palette.sea)),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppText.display(28)),
              const SizedBox(height: 20),
              Text('UNITS', style: AppText.label()),
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('°C · km/h · m')),
                  ButtonSegment(value: true, label: Text('°F · mph · ft')),
                ],
                selected: {imperial},
                showSelectedIcon: false,
                onSelectionChanged: (s) => c.setImperial(s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Palette.ink,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: Palette.ink,
                  side: const BorderSide(color: Palette.line),
                  textStyle: AppText.body(13, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 28),
              Text('BEACH BUDDY AI', style: AppText.label()),
              const SizedBox(height: 6),
              Text(
                'Runs on open-source models (Llama, Qwen, Mistral) through any OpenAI-compatible server. '
                'Ollama is free and runs on your own computer. Groq, OpenRouter and Hugging Face host '
                'open models in the cloud with a free API key.',
                style: AppText.body(13, color: Palette.inkSoft),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in AiConfig.presets.entries)
                    ChoiceChip(
                      label: Text(e.key),
                      selected: _url.text == e.value.baseUrl,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _url.text = e.value.baseUrl;
                        _model.text = e.value.model;
                      }),
                      labelStyle: AppText.body(13,
                          color: _url.text == e.value.baseUrl ? Colors.white : Palette.ink, weight: FontWeight.w600),
                      selectedColor: Palette.ink,
                      backgroundColor: Palette.paper,
                      side: const BorderSide(color: Palette.line),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: _url, decoration: deco('Server URL'), style: AppText.body(15)),
              const SizedBox(height: 10),
              TextField(controller: _model, decoration: deco('Model'), style: AppText.body(15)),
              const SizedBox(height: 10),
              TextField(
                controller: _key,
                obscureText: _hideKey,
                style: AppText.body(15),
                decoration: deco('API key (leave empty for Ollama)',
                    suffix: IconButton(
                      onPressed: () => setState(() => _hideKey = !_hideKey),
                      icon: Icon(_hideKey ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Palette.inkSoft),
                    )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Save', style: AppText.body(15, color: Colors.white, weight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
