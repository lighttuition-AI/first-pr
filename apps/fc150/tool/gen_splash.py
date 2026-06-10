#!/usr/bin/env python3
"""Generate the FC150 launch/splash logo — the stacked "FC" + "150" brand
wordmark on a TRANSPARENT background, with the electric purple->teal gradient
and a soft glow. flutter_native_splash centers this over the dark brand color
(#0A0A0F), so the logo itself must be transparent (no background box).

Run: python3 tool/gen_splash.py  (writes assets/splash/splash_logo.png)
Then: dart run flutter_native_splash:create
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

S = 1200                    # square canvas; fits both iOS center + Android-12 circle
PURPLE = (124, 108, 248)    # #7C6CF8
TEAL = (0, 216, 214)        # #00D8D6
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "splash", "splash_logo.png")

ARIAL_BLACK = "/System/Library/Fonts/Supplemental/Arial Black.ttf"
ARIAL_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def diag_grad(a, b, w, h):
    small = 128
    g = Image.new("RGB", (small, small))
    px = g.load()
    for y in range(small):
        for x in range(small):
            t = (x + y) / (2 * (small - 1))
            px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
    return g.resize((w, h))


canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
draw = ImageDraw.Draw(canvas)

big = ImageFont.truetype(ARIAL_BLACK, 520)
small_f = ImageFont.truetype(ARIAL_BOLD, 188)

# measure "150" and "FC"
b150 = draw.textbbox((0, 0), "150", font=big)
w150, h150 = b150[2] - b150[0], b150[3] - b150[1]

fc = "FC"
spacing = 32
fc_widths = [draw.textbbox((0, 0), c, font=small_f)[2] - draw.textbbox((0, 0), c, font=small_f)[0] for c in fc]
fc_w = sum(fc_widths) + spacing * (len(fc) - 1)
fcb = draw.textbbox((0, 0), "FC", font=small_f)
fc_h = fcb[3] - fcb[1]

gap = 40
total_h = fc_h + gap + h150
top_y = (S - total_h) // 2

# --- "FC" in teal, letter-spaced, centered ---
fx = (S - fc_w) // 2
fc_top = top_y
for i, c in enumerate(fc):
    cb = draw.textbbox((0, 0), c, font=small_f)
    draw.text((fx - cb[0], fc_top - fcb[1]), c, font=small_f, fill=TEAL + (255,))
    fx += fc_widths[i] + spacing

# --- "150" mask filled with the diagonal brand gradient + soft glow ---
mask = Image.new("L", (S, S), 0)
mdraw = ImageDraw.Draw(mask)
x150 = (S - w150) // 2
y150 = top_y + fc_h + gap
mdraw.text((x150 - b150[0], y150 - b150[1]), "150", font=big, fill=255)

# glow behind the numerals (composited into the transparent canvas)
glowm = mask.filter(ImageFilter.GaussianBlur(30)).point(lambda v: int(v * 0.6))
glow_rgba = Image.new("RGBA", (S, S), (150, 190, 255, 0))
glow_rgba.putalpha(glowm)
canvas = Image.alpha_composite(canvas, glow_rgba)

grad = diag_grad(PURPLE, TEAL, S, S)
white = Image.new("RGB", (S, S), (255, 255, 255))
grad = Image.blend(grad, white, 0.18).convert("RGBA")
grad.putalpha(mask)  # keep only the "150" shape
canvas = Image.alpha_composite(canvas, grad)

os.makedirs(os.path.dirname(OUT), exist_ok=True)
canvas.save(OUT, "PNG")
print("wrote", os.path.abspath(OUT), canvas.size)

# --- Android 12+ variant -----------------------------------------------------
# Android 12's splash API masks the icon to a CIRCLE ~2/3 of the canvas
# (a 768px circle on a 1152px canvas). The full-width wordmark above would be
# clipped, so derive a smaller, centered logo that sits comfortably inside that
# circle. Same artwork as iOS — just scaled to survive the mask (iOS is left
# untouched as the reference). Width target ~58% of the canvas keeps the
# left/right extremes of "150" (the binding points) well inside the circle.
A12 = 1152
A12_OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "splash", "splash_logo_android12.png")
crop = canvas.crop(canvas.getbbox())               # tight logo (incl. glow)
target_w = int(A12 * 0.54)
scale = target_w / crop.width
scaled = crop.resize((target_w, max(1, round(crop.height * scale))), Image.LANCZOS)
a12 = Image.new("RGBA", (A12, A12), (0, 0, 0, 0))
a12.alpha_composite(scaled, ((A12 - scaled.width) // 2, (A12 - scaled.height) // 2))
a12.save(A12_OUT, "PNG")
print("wrote", os.path.abspath(A12_OUT), a12.size,
      f"(logo {scaled.size}, radius {round((scaled.width**2 + scaled.height**2) ** 0.5 / 2)}px vs 384px circle)")
