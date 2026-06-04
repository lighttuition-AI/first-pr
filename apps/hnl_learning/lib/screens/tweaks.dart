// Floating Tweaks panel — designer/parent live options. Maps
// cleanly to in-app Settings. (Ported from tweaks-panel.jsx.)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/tokens.dart';

class TweaksButton extends StatelessWidget {
  const TweaksButton({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return GestureDetector(
      onTap: app.toggleTweaks,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: C.ink, shape: BoxShape.circle, boxShadow: Sh.md),
        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}

class TweaksPanel extends StatelessWidget {
  const TweaksPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(onTap: app.toggleTweaks, child: ColoredBox(color: C.inkA(.25))),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 420,
            height: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 40)],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Tweaks', style: AppText.h2.copyWith(fontSize: 40)),
                      const Spacer(),
                      GestureDetector(
                        onTap: app.toggleTweaks,
                        child: const Icon(Icons.close_rounded, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _section('Look & feel'),
                  _segment('Color theme', ['Meadow', 'Cosmic', 'Candy'],
                      {'meadow': 'Meadow', 'cosmic': 'Cosmic', 'candy': 'Candy'}[app.palette]!,
                      (v) => app.setTweak(() => app.palette = {'Meadow': 'meadow', 'Cosmic': 'cosmic', 'Candy': 'candy'}[v]!)),
                  _segment('Font', ['Rounded', 'Geometric'], app.font == 'quick' ? 'Geometric' : 'Rounded',
                      (v) => app.setTweak(() => app.font = v == 'Geometric' ? 'quick' : 'baloo')),
                  _section('Play'),
                  _segment('Celebration', ['Big', 'Gentle'], app.celebration == 'gentle' ? 'Gentle' : 'Big',
                      (v) => app.setTweak(() => app.celebration = v == 'Gentle' ? 'gentle' : 'big')),
                  _SliderRow(
                    label: 'Session length',
                    value: app.sessionLen,
                    onChanged: (v) => app.setTweak(() => app.sessionLen = v),
                  ),
                  _section('Guide & sound'),
                  _toggleRow('Show Robo mascot', app.mascot, () => app.setTweak(() => app.mascot = !app.mascot)),
                  _toggleRow('Sound & voiceover', app.sound, () => app.setTweak(() => app.sound = !app.sound)),
                  const SizedBox(height: 20),
                  _panelButton('Record my voice 🎙️', () {
                    app.toggleTweaks();
                    app.openVoiceStudio();
                  }),
                  const SizedBox(height: 12),
                  _panelButton('Use my own pictures 🖼️', () {
                    app.toggleTweaks();
                    app.openPictureStudio();
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(label.toUpperCase(), style: AppText.kicker),
      );

  Widget _segment(String label, List<String> options, String value, ValueChanged<String> onChange) {
    return Builder(builder: (context) {
      final pal = context.watch<AppState>().pal;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.body(size: 22, weight: FontWeight.w700, color: C.inkSoft)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(R.pill)),
              child: Row(
                children: [
                  for (final o in options)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChange(o),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: o == value ? pal.brand : Colors.transparent,
                            borderRadius: BorderRadius.circular(R.pill),
                          ),
                          child: Text(o,
                              style: AppText.display(
                                  size: 22,
                                  weight: FontWeight.w700,
                                  color: o == value ? Colors.white : C.inkSoft)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _toggleRow(String label, bool value, VoidCallback onTap) {
    return Builder(builder: (context) {
      final pal = context.watch<AppState>().pal;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.body(size: 22, weight: FontWeight.w700))),
            GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 70,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: value ? pal.brand : C.muted, borderRadius: BorderRadius.circular(R.pill)),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 160),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _panelButton(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: C.cream, borderRadius: BorderRadius.circular(R.md), border: Border.all(color: C.sun, width: 2)),
          child: Text(label, style: AppText.display(size: 24, weight: FontWeight.w700)),
        ),
      );
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _SliderRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final pal = context.watch<AppState>().pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppText.body(size: 22, weight: FontWeight.w700, color: C.inkSoft)),
              const Spacer(),
              Text('$value min', style: AppText.display(size: 22, weight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: pal.brand, thumbColor: pal.brand),
            child: Slider(
              value: value.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}
