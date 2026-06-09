import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

// ---------------------------------------------------------------------------
// Eyebrow — tiny uppercase wide-tracked label.
// ---------------------------------------------------------------------------
class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;
  const Eyebrow(this.text, {super.key, this.color = FC.textMuted});

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: FCType.eyebrow(color: color));
}

// ---------------------------------------------------------------------------
// Pill / tag.
// ---------------------------------------------------------------------------
enum PillTone { neutral, purple, teal, success, warning, danger }

class _ToneSpec {
  final Color bg, border, fg;
  const _ToneSpec(this.bg, this.border, this.fg);
}

const _toneSpecs = {
  PillTone.neutral: _ToneSpec(FC.overlay, FC.borderStrong, FC.text2),
  PillTone.purple: _ToneSpec(FC.purpleTint, Color(0x737C6CF8), FC.purple300),
  PillTone.teal: _ToneSpec(FC.tealTint, Color(0x6600D8D6), FC.teal),
  PillTone.success: _ToneSpec(FC.successTint, Color(0x6600C853), FC.success),
  PillTone.warning: _ToneSpec(FC.warningTint, Color(0x66FFB300), FC.warning),
  PillTone.danger: _ToneSpec(FC.dangerTint, Color(0x66FF5252), FC.danger),
};

class Pill extends StatelessWidget {
  final String label;
  final String? glyph;
  final PillTone tone;
  const Pill(this.label, {super.key, this.glyph, this.tone = PillTone.neutral});

  @override
  Widget build(BuildContext context) {
    final s = _toneSpecs[tone]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(FC.rPill),
        border: Border.all(color: s.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            Text(glyph!, style: FCType.mono(size: 11.5, weight: FontWeight.w600, color: s.fg)),
            const SizedBox(width: 5),
          ],
          Text(label, style: FCType.body(size: 11.5, weight: FontWeight.w600, color: s.fg, height: 1)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status pill — challenge / match state machine.
// ---------------------------------------------------------------------------
class _Status {
  final String glyph;
  final PillTone tone;
  final String label;
  const _Status(this.glyph, this.tone, this.label);
}

const Map<String, _Status> kStatus = {
  'pending': _Status('◷', PillTone.warning, 'Pending'),
  'accepted': _Status('●', PillTone.purple, 'Accepted'),
  'declined': _Status('×', PillTone.danger, 'Declined'),
  'locked': _Status('◆', PillTone.teal, 'Locked'),
  'completed': _Status('✓', PillTone.success, 'Completed'),
  'confirmed': _Status('✓', PillTone.success, 'Confirmed'),
  'disputed': _Status('▲', PillTone.danger, 'Disputed'),
  'noshow': _Status('▲', PillTone.danger, 'No-show 3–0'),
  'scheduled': _Status('◷', PillTone.neutral, 'Scheduled'),
};

class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill(this.status, {super.key});
  @override
  Widget build(BuildContext context) {
    final s = kStatus[status] ?? kStatus['scheduled']!;
    return Pill(s.label, glyph: s.glyph, tone: s.tone);
  }
}

// ---------------------------------------------------------------------------
// GButton — gaming-glow primary / secondary / teal / danger / ghost.
// ---------------------------------------------------------------------------
enum GBtn { primary, secondary, teal, danger, ghost }

class GButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final GBtn variant;
  final String size; // sm / md / lg
  final IconData? icon;
  final bool full;
  final bool disabled;
  const GButton(
    this.label, {
    super.key,
    this.onTap,
    this.variant = GBtn.primary,
    this.size = 'lg',
    this.icon,
    this.full = false,
    this.disabled = false,
  });

  @override
  State<GButton> createState() => _GButtonState();
}

class _GButtonState extends State<GButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.size == 'sm' ? 38.0 : widget.size == 'md' ? 46.0 : 54.0;
    final fs = widget.size == 'sm' ? 13.0 : 15.0;

    Gradient? grad;
    Color? fill;
    Color fg = Colors.white;
    Border? border;
    List<BoxShadow>? glow;
    switch (widget.variant) {
      case GBtn.primary:
        grad = FC.gradient;
        glow = FC.glowPurpleSm;
        break;
      case GBtn.secondary:
        fill = FC.overlay;
        border = Border.all(color: FC.borderStrong);
        break;
      case GBtn.teal:
        grad = FC.tealButton;
        fg = const Color(0xFF04201F);
        glow = FC.glowTeal;
        break;
      case GBtn.danger:
        fill = FC.danger;
        glow = FC.glowDanger;
        break;
      case GBtn.ghost:
        fill = Colors.transparent;
        border = Border.all(color: FC.borderStrong);
        fg = FC.text;
        break;
    }

    final child = AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: FC.durFast,
      child: Container(
        height: h,
        width: widget.full ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: grad,
          color: fill,
          borderRadius: BorderRadius.circular(FC.rButton),
          border: border,
          boxShadow: glow,
        ),
        child: Row(
          mainAxisSize: widget.full ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: widget.size == 'sm' ? 16 : 18, color: fg),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FCType.body(size: fs, weight: FontWeight.w700, color: fg, height: 1)),
            ),
          ],
        ),
      ),
    );

    return Opacity(
      opacity: widget.disabled ? 0.5 : 1,
      child: GestureDetector(
        onTapDown: widget.disabled ? null : (_) => setState(() => _down = true),
        onTapUp: widget.disabled ? null : (_) => setState(() => _down = false),
        onTapCancel: widget.disabled ? null : () => setState(() => _down = false),
        onTap: widget.disabled ? null : widget.onTap,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Surface — the base card (dark fill, hairline border, optional purple glow).
// ---------------------------------------------------------------------------
class Surface extends StatelessWidget {
  final Widget child;
  final double pad;
  final bool glow;
  final Color? borderColor;
  final VoidCallback? onTap;
  const Surface({super.key, required this.child, this.pad = 16, this.glow = false, this.borderColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: FC.surface,
        borderRadius: BorderRadius.circular(FC.rCard),
        border: Border.all(color: borderColor ?? FC.border),
        boxShadow: glow ? FC.glowPurpleSm : null,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

// ---------------------------------------------------------------------------
// Section title with optional trailing action link.
// ---------------------------------------------------------------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: FCType.heading(size: 17, weight: FontWeight.w700, letterSpacing: -0.02 * 17)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: FCType.body(size: 12.5, weight: FontWeight.w600, color: FC.purple300)),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented control.
// ---------------------------------------------------------------------------
class Segmented extends StatelessWidget {
  final List<MapEntry<String, String>> tabs; // key -> label
  final String value;
  final ValueChanged<String> onChange;
  const Segmented({super.key, required this.tabs, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FC.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FC.border),
      ),
      child: Row(
        children: [
          for (final t in tabs)
            Expanded(
              child: GestureDetector(
                onTap: () => onChange(t.key),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: value == t.key ? FC.overlay : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: value == t.key ? Border.all(color: FC.borderStrong) : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(t.value,
                        maxLines: 1,
                        style: FCType.body(size: 13, weight: FontWeight.w600, color: value == t.key ? Colors.white : FC.text2, height: 1)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini stat bars (profile + card detail).
// ---------------------------------------------------------------------------
const _statLabels = {
  'pac': 'Pace', 'sho': 'Shooting', 'pas': 'Passing',
  'dri': 'Dribbling', 'def': 'Defence', 'phy': 'Physical',
};

class StatBars extends StatelessWidget {
  final Map<String, int> stats;
  final bool animate;
  const StatBars({super.key, required this.stats, this.animate = false});

  @override
  Widget build(BuildContext context) {
    final keys = _statLabels.keys.toList();
    return Column(
      children: [
        for (int i = 0; i < keys.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _bar(keys[i])),
                const SizedBox(width: 18),
                Expanded(child: i + 1 < keys.length ? _bar(keys[i + 1]) : const SizedBox()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _bar(String k) {
    final v = stats[k] ?? 0;
    final c = FC.statColor(v);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_statLabels[k]!, style: FCType.body(size: 11.5, weight: FontWeight.w600, color: FC.text2, height: 1)),
            Text('$v', style: FCType.mono(size: 12.5, weight: FontWeight.w700, color: c)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 5, color: Colors.white.withValues(alpha: 0.08)),
              LayoutBuilder(
                builder: (_, c2) => animate
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: v / 100),
                        duration: const Duration(milliseconds: 1000),
                        curve: FC.easeOut,
                        builder: (_, t, __) => Container(height: 5, width: c2.maxWidth * t, color: c),
                      )
                    : Container(height: 5, width: c2.maxWidth * (v / 100), color: c),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Count-up number.
// ---------------------------------------------------------------------------
class CountUp extends StatelessWidget {
  final int from, to;
  final TextStyle style;
  final Duration duration;
  const CountUp({super.key, required this.from, required this.to, required this.style, this.duration = const Duration(milliseconds: 900)});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from.toDouble(), end: to.toDouble()),
      duration: duration,
      curve: FC.easeOut,
      builder: (_, v, __) => Text('${v.round()}', style: style),
    );
  }
}

// ---------------------------------------------------------------------------
// Confetti burst — celebratory, blasts down/outward from top-centre.
// ---------------------------------------------------------------------------
class FCConfetti extends StatefulWidget {
  final ConfettiController controller;
  const FCConfetti(this.controller, {super.key});
  @override
  State<FCConfetti> createState() => _FCConfettiState();
}

class _FCConfettiState extends State<FCConfetti> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.4),
      child: ConfettiWidget(
        confettiController: widget.controller,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.0,
        numberOfParticles: 30,
        maxBlastForce: 22,
        minBlastForce: 8,
        gravity: 0.25,
        shouldLoop: false,
        colors: const [
          FC.purple, FC.teal, FC.success, FC.warning, FC.danger, Color(0xFF8FF6FF),
        ],
      ),
    );
  }
}
