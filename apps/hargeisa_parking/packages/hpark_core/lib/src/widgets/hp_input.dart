import 'package:flutter/material.dart';

import '../theme/hp_colors.dart';
import '../theme/hp_spacing.dart';
import '../theme/hp_typography.dart';

/// Text field on a dark surface, with an optional label, hint, leading icon,
/// and error. A [mono] mode renders the value in JetBrains Mono (plates / IDs).
class HpInput extends StatelessWidget {
  const HpInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.error,
    this.keyboardType,
    this.obscure = false,
    this.mono = false,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? icon;
  final String? error;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool mono;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: HpType.body(size: 13, weight: FontWeight.w600, color: HpColors.text2)),
          const SizedBox(height: HpSpace.x2),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscure,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: mono
              ? HpType.mono(size: 16, weight: FontWeight.w600, letterSpacing: 0.5)
              : HpType.body(size: 15, color: HpColors.text),
          cursorColor: HpColors.purple,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: HpColors.overlay,
            hintText: hint,
            hintStyle: HpType.body(size: 15, color: HpColors.textMuted),
            prefixIcon: icon == null ? null : Icon(icon, size: 18, color: HpColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: HpSpace.x4, vertical: 14),
            border: _border(HpColors.border),
            enabledBorder: _border(hasError ? HpColors.danger : HpColors.border),
            focusedBorder: _border(hasError ? HpColors.danger : HpColors.borderFocus),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(error!, style: HpType.body(size: 12, color: HpColors.danger)),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(HpRadius.sm),
        borderSide: BorderSide(color: color, width: 1),
      );
}
