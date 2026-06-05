// Voiceover Studio — record / upload / re-record / delete your own voice or
// sound for every line in the app. Clips play back automatically wherever that
// line is spoken, at their natural length. Now also the one home for every
// animal's sound + names (by continent). (Ported from the Studio UI in
// js/vo.jsx, then extended.)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../models/animals.dart';
import '../models/content.dart';
import '../services/vo_service.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/kid_button.dart';

class VoiceStudio extends StatefulWidget {
  const VoiceStudio({super.key});
  @override
  State<VoiceStudio> createState() => _VoiceStudioState();
}

class _VoiceStudioState extends State<VoiceStudio> {
  final groups = buildVoRegistry();
  // Which section is open. App lines use the group name; animal continents use
  // 'cont:<id>' — so only one section is ever open across the whole studio.
  late String? _open = groups.first.group;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final vo = context.watch<VoService>();
    return Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTap: app.closeVoiceStudio, child: ColoredBox(color: C.inkA(.45)))),
        Center(
          child: Container(
            width: 1040,
            constraints: const BoxConstraints(maxHeight: 900),
            decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.xl), boxShadow: Sh.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 34, 30, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VOICEOVER STUDIO', style: AppText.kicker),
                            const SizedBox(height: 6),
                            Text('Record or upload your own', style: AppText.h2),
                            const SizedBox(height: 8),
                            Text(
                              'Hit record and read the line aloud, or upload a sound you saved (a Voice Memo, '
                              'or a clip from the web). Your clip plays whenever the speaker is tapped — on '
                              'every screen. Scroll down for every animal’s sound.',
                              style: AppText.lead.copyWith(fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                      IconCircle(Icons.close_rounded, onTap: app.closeVoiceStudio),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 34),
                    child: Column(
                      children: [
                        for (final g in groups)
                          _GroupTile(
                            group: g,
                            open: _open == g.group,
                            recordedCount: g.lines.where((l) => vo.has(l.id)).length,
                            onToggle: () => setState(() => _open = _open == g.group ? null : g.group),
                          ),
                        // ---- Animals: every continent's sounds + names ----
                        const Padding(
                          padding: EdgeInsets.fromLTRB(4, 18, 4, 10),
                          child: _SectionLabel('ANIMALS — SOUNDS & NAMES'),
                        ),
                        for (final c in kContinents)
                          _ContinentTile(
                            continent: c,
                            open: _open == 'cont:${c.id}',
                            onToggle: () => setState(() => _open = _open == 'cont:${c.id}' ? null : 'cont:${c.id}'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: AppText.kicker),
      );
}

class _GroupTile extends StatelessWidget {
  final VoGroup group;
  final bool open;
  final int recordedCount;
  final VoidCallback onToggle;
  const _GroupTile({required this.group, required this.open, required this.recordedCount, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.md), boxShadow: Sh.sm),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(child: Text(group.group, style: AppText.display(size: 28, weight: FontWeight.w700))),
                  Text('$recordedCount/${group.lines.length} 🎙️',
                      style: AppText.body(size: 22, weight: FontWeight.w700, color: C.muted)),
                  const SizedBox(width: 12),
                  Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(children: [for (final l in group.lines) _VoLineRow(line: l)]),
            ),
        ],
      ),
    );
  }
}

// ---- One continent (e.g. Africa): lists its animals ----
class _ContinentTile extends StatelessWidget {
  final Continent continent;
  final bool open;
  final VoidCallback onToggle;
  const _ContinentTile({required this.continent, required this.open, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final vo = context.watch<VoService>();
    final clips = continent.pool.fold<int>(0, (n, a) => n + _animalIds(a.id).where(vo.has).length);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(R.md), boxShadow: Sh.sm),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              color: Colors.transparent,
              child: Row(
                children: [
                  Text(continent.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(continent.name, style: AppText.display(size: 28, weight: FontWeight.w700))),
                  Text(clips > 0 ? '$clips 🎙️' : '${continent.pool.length} animals',
                      style: AppText.body(size: 22, weight: FontWeight.w700, color: C.muted)),
                  const SizedBox(width: 12),
                  Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(children: [for (final a in continent.pool) _AnimalTile(animal: a)]),
            ),
        ],
      ),
    );
  }
}

// ---- One animal: expands to its Sound + Somali + English clips ----
class _AnimalTile extends StatefulWidget {
  final Animal animal;
  const _AnimalTile({required this.animal});
  @override
  State<_AnimalTile> createState() => _AnimalTileState();
}

class _AnimalTileState extends State<_AnimalTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final vo = context.watch<VoService>();
    final a = widget.animal;
    final ids = _animalIds(a.id);
    final hasAny = ids.any(vo.has);
    final lines = <VoLineData>[
      VoLineData('animal-${a.id}-sound', a.sound, 'Animal sound'),
      VoLineData('animal-${a.id}-so', a.so, 'Somali name', lang: 'so-SO'),
      VoLineData('animal-${a.id}-en', a.en, 'English name'),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: C.paper,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: C.line),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.transparent,
              child: Row(
                children: [
                  Text(a.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.en, style: AppText.body(size: 22, weight: FontWeight.w800)),
                        Text(a.so, style: AppText.body(size: 18, weight: FontWeight.w700, color: C.muted)),
                      ],
                    ),
                  ),
                  if (hasAny)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text('🎙️', style: AppText.body(size: 20)),
                    ),
                  Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Column(children: [for (final l in lines) _VoLineRow(line: l)]),
            ),
        ],
      ),
    );
  }
}

/// The three recordable clip ids for an animal: sound, Somali name, English.
List<String> _animalIds(String id) => ['animal-$id-sound', 'animal-$id-so', 'animal-$id-en'];

class _VoLineRow extends StatefulWidget {
  final VoLineData line;
  const _VoLineRow({required this.line});
  @override
  State<_VoLineRow> createState() => _VoLineRowState();
}

class _VoLineRowState extends State<_VoLineRow> {
  final AudioRecorder _rec = AudioRecorder();
  bool _recording = false;
  bool _busy = false; // an upload is in progress
  String _warn = '';

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final vo = context.read<VoService>();
    if (_recording) {
      final path = await _rec.stop();
      setState(() => _recording = false);
      if (path != null) vo.registerRecording(widget.line.id, path);
    } else {
      try {
        if (!await _rec.hasPermission()) {
          setState(() => _warn = 'Microphone blocked — allow mic access to record.');
          return;
        }
        String path = '';
        if (!kIsWeb) {
          final dir = await getApplicationDocumentsDirectory();
          path = '${dir.path}/vo_${widget.line.id}.m4a';
        }
        await _rec.start(const RecordConfig(), path: path);
        setState(() {
          _recording = true;
          _warn = '';
        });
      } catch (_) {
        setState(() => _warn = "Recording isn't available here. Open on a device to record.");
      }
    }
  }

  Future<void> _upload() async {
    if (_busy || _recording) return;
    final vo = context.read<VoService>();
    setState(() {
      _busy = true;
      _warn = '';
    });
    final r = await vo.importFile(widget.line.id);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r == ImportResult.failed) {
        _warn = "Couldn't upload here — open on a device and pick an audio file from Files.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vo = context.watch<VoService>();
    final has = vo.has(widget.line.id);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: C.paper, borderRadius: BorderRadius.circular(R.md), border: Border.all(color: C.line)),
      child: Row(
        children: [
          // Record button
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _recording ? const Color(0xFFE0573D) : (has ? const Color(0xFF15B886) : Colors.white),
                shape: BoxShape.circle,
                boxShadow: Sh.sm,
              ),
              child: _recording
                  ? const Icon(Icons.stop_rounded, color: Colors.white, size: 26)
                  : Icon(Icons.fiber_manual_record_rounded, color: has ? Colors.white : const Color(0xFFE0573D), size: 24),
            ),
          ),
          const SizedBox(width: 10),
          // Upload button — pick an existing audio file
          GestureDetector(
            onTap: _upload,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: Sh.sm,
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.6, color: Color(0xFF3F7FD6)),
                    )
                  : const Icon(Icons.upload_rounded, color: Color(0xFF3F7FD6), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.line.where, style: AppText.body(size: 20, weight: FontWeight.w800, color: C.muted)),
                Text('"${widget.line.text}"', style: AppText.body(size: 23, weight: FontWeight.w700)),
                if (_warn.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_warn, style: AppText.body(size: 18, weight: FontWeight.w700, color: const Color(0xFFE0573D))),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => vo.play(widget.line.id, widget.line.text, lang: widget.line.lang, asset: widget.line.asset),
            icon: const Icon(Icons.play_arrow_rounded, size: 32),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: has ? const Color(0xFFC9F0E0) : C.line,
              borderRadius: BorderRadius.circular(R.pill),
            ),
            child: Text(has ? '🎙️ yours' : 'default',
                style: AppText.body(size: 18, weight: FontWeight.w800, color: C.inkSoft)),
          ),
          if (has)
            IconButton(
              onPressed: () => vo.removeRecording(widget.line.id),
              icon: const Icon(Icons.close_rounded, size: 26, color: Color(0xFFE0573D)),
            ),
        ],
      ),
    );
  }
}
