#!/usr/bin/env python3
"""Generate the FC150 app icon (1024x1024, no alpha) — dark base with the
electric purple->teal brand glow and a gradient "150" wordmark under "FC".
Run: python3 tool/gen_icon.py  (writes assets/icon/app_icon.png)
"""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

S = 1024
PURPLE = (124, 108, 248)   # #7C6CF8
TEAL = (0, 216, 214)       # #00D8D6
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "icon", "app_icon.png")

ARIAL_BLACK = "/System/Library/Fonts/Supplemental/Arial Black.ttf"
ARIAL_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def vgrad(top, bot, w, h):
    g = Image.new("RGB", (1, h))
    px = g.load()
    for y in range(h):
        t = y / (h - 1)
        px[0, y] = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
    return g.resize((w, h))


def diag_grad(a, b, w, h):
    small = 128
    g = Image.new("RGB", (small, small))
    px = g.load()
    for y in range(small):
        for x in range(small):
            t = (x + y) / (2 * (small - 1))
            px[x, y] = tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))
    return g.resize((w, h))


# --- background: dark vertical gradient + two soft brand glows ---
bg = vgrad((26, 24, 56), (10, 10, 15), S, S).convert("RGBA")  # #1A1838 -> #0A0A0F
glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
gd = ImageDraw.Draw(glow)
gd.ellipse([-260, -300, 640, 600], fill=PURPLE + (170,))      # upper-left purple
gd.ellipse([440, 500, 1320, 1380], fill=TEAL + (140,))        # lower-right teal
glow = glow.filter(ImageFilter.GaussianBlur(170))
bg = Image.alpha_composite(bg, glow).convert("RGB")

# subtle inner vignette to deepen the corners
vig = Image.new("L", (S, S), 0)
ImageDraw.Draw(vig).ellipse([-120, -120, S + 120, S + 120], fill=255)
vig = vig.filter(ImageFilter.GaussianBlur(120))
dark = Image.new("RGB", (S, S), (6, 6, 12))
bg = Image.composite(bg, dark, vig)

draw = ImageDraw.Draw(bg)
big = ImageFont.truetype(ARIAL_BLACK, 430)
small = ImageFont.truetype(ARIAL_BOLD, 150)

# measure "150" and "FC"
b150 = draw.textbbox((0, 0), "150", font=big)
w150, h150 = b150[2] - b150[0], b150[3] - b150[1]
# "FC" letter-spaced
fc = "FC"
spacing = 26
fc_widths = [draw.textbbox((0, 0), c, font=small)[2] - draw.textbbox((0, 0), c, font=small)[0] for c in fc]
fc_w = sum(fc_widths) + spacing * (len(fc) - 1)
fc_h = draw.textbbox((0, 0), "FC", font=small)[3] - draw.textbbox((0, 0), "FC", font=small)[1]

gap = 34
total_h = fc_h + gap + h150
top_y = (S - total_h) // 2

# --- "FC" in teal, letter-spaced, centered ---
fx = (S - fc_w) // 2
fc_top = top_y
fcb = draw.textbbox((0, 0), "FC", font=small)
for i, c in enumerate(fc):
    cb = draw.textbbox((0, 0), c, font=small)
    draw.text((fx - cb[0], fc_top - fcb[1]), c, font=small, fill=TEAL)
    fx += fc_widths[i] + spacing

# --- "150" filled with the diagonal brand gradient + soft glow ---
mask = Image.new("L", (S, S), 0)
mdraw = ImageDraw.Draw(mask)
x150 = (S - w150) // 2
y150 = top_y + fc_h + gap
mdraw.text((x150 - b150[0], y150 - b150[1]), "150", font=big, fill=255)

# glow behind the numerals
glowm = mask.filter(ImageFilter.GaussianBlur(26))
glow_col = Image.new("RGB", (S, S), (150, 190, 255))
bg = Image.composite(glow_col, bg, glowm.point(lambda v: int(v * 0.55)))

grad = diag_grad(PURPLE, TEAL, S, S)
# lift the gradient toward white at the top-left for a glossy read
white = Image.new("RGB", (S, S), (255, 255, 255))
grad = Image.blend(grad, white, 0.18)
bg.paste(grad, (0, 0), mask)

os.makedirs(os.path.dirname(OUT), exist_ok=True)
bg.convert("RGB").save(OUT, "PNG")
print("wrote", os.path.abspath(OUT), bg.size)
