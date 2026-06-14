// The universal editable picture. Shows the uploaded image if one
// exists for this slot, else the original emoji — so nothing ever
// looks broken. Mirrors <Img> from js/img.jsx.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/image_service.dart';
import '../theme/tokens.dart';

class Img extends StatelessWidget {
  final String token; // emoji / natural token
  final String? id; // explicit slot id (else imgTokenId(token))
  final String? display; // glyph override (e.g. gate number)
  final double size; // emoji font-size / square box size
  final bool fill; // fill the parent box (cover)
  final double? radius;
  final String? asset; // bundled asset image, used when no upload exists

  const Img(
    this.token, {
    super.key,
    this.id,
    this.display,
    this.size = 40,
    this.fill = false,
    this.radius,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ImageService>();
    final slotId = id ?? imgTokenId(token);
    final bytes = svc.bytesFor(slotId);
    final glyph = display ?? token;

    // Priority: a grown-up's uploaded image → a bundled asset → the emoji.
    Widget? picture;
    if (bytes != null) {
      picture = Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (asset != null) {
      // errorBuilder → fall back to the emoji glyph if the asset is missing.
      picture = Image.asset(asset!, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Center(child: Text(glyph, style: TextStyle(fontSize: size, color: C.ink))));
    }
    if (picture != null) {
      if (fill) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius ?? R.md),
          child: SizedBox.expand(child: picture),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? size * 0.2),
        child: SizedBox(width: size, height: size, child: picture),
      );
    }

    // No forced line-height: emoji glyphs are taller than `height: 1.0`,
    // which would clip them and trigger per-emoji overflow stripes.
    // Tint with the skin's ink so text glyphs (numbers/letters) stay legible
    // on dark looks; colour emoji ignore the tint and render full-colour.
    final text = Text(glyph,
        style: TextStyle(fontSize: size, color: C.ink), textAlign: TextAlign.center);
    return fill ? Center(child: text) : text;
  }
}
