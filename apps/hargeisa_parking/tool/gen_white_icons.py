"""HPark app icons: white background + brand gradient "P" (matches the Command
dashboard) with a per-app badge — checkmark circle for Pay, shield for Enforce."""
import math
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
PURPLE = (124, 108, 248)   # #7C6CF8
TEAL = (0, 216, 214)       # #00D8D6
WHITE = (255, 255, 255, 255)

try:
    import numpy as np
    yy, xx = np.mgrid[0:SIZE, 0:SIZE]
    t = (xx + yy) / (2 * (SIZE - 1))
    r = (PURPLE[0] + (TEAL[0] - PURPLE[0]) * t).astype('uint8')
    g = (PURPLE[1] + (TEAL[1] - PURPLE[1]) * t).astype('uint8')
    b = (PURPLE[2] + (TEAL[2] - PURPLE[2]) * t).astype('uint8')
    GRAD = Image.fromarray(np.dstack([r, g, b]), 'RGB').convert('RGBA')
except Exception:
    GRAD = Image.new('RGBA', (SIZE, SIZE), PURPLE + (255,))

FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Black.ttf"


def grad_over(x0, y0, w, h):
    """Vertical purple(top)->teal(bottom) gradient mapped across [y0, y0+h], so
    the glyph spans the full brand gradient. numpy-free: build a 1px-wide ramp
    and stretch it across the canvas (fast + no dependency)."""
    col = Image.new('RGB', (1, SIZE))
    cp = col.load()
    for y in range(SIZE):
        t = (y - y0) / h
        t = 0.0 if t < 0 else (1.0 if t > 1 else t)
        cp[0, y] = (int(PURPLE[0] + (TEAL[0] - PURPLE[0]) * t),
                    int(PURPLE[1] + (TEAL[1] - PURPLE[1]) * t),
                    int(PURPLE[2] + (TEAL[2] - PURPLE[2]) * t))
    return col.resize((SIZE, SIZE)).convert('RGBA')


def paste_p(canvas, cx, cy, font_size):
    mask = Image.new('L', (SIZE, SIZE), 0)
    d = ImageDraw.Draw(mask)
    font = ImageFont.truetype(FONT_PATH, font_size)
    l, t, r, b = d.textbbox((0, 0), "P", font=font)
    d.text((cx - (r - l) / 2 - l, cy - (b - t) / 2 - t), "P", fill=255, font=font)
    il, it, ir, ib = mask.getbbox()  # true ink bounds (font metrics vary)
    canvas.paste(grad_over(il, it, ir - il, ib - it), (0, 0), mask)


def draw_check(d, bx, by, rb, width):
    pts = [(bx - 0.34 * rb, by + 0.02 * rb),
           (bx - 0.07 * rb, by + 0.28 * rb),
           (bx + 0.42 * rb, by - 0.30 * rb)]
    d.line(pts, fill=WHITE, width=int(width), joint='curve')
    rc = width / 2
    for px, py in (pts[0], pts[2]):
        d.ellipse([px - rc, py - rc, px + rc, py + rc], fill=WHITE)


def shield(cx, cy, w, h):
    hw, hh, rc = w / 2, h / 2, w * 0.18
    pts = []
    for a in range(180, 271, 9):
        pts.append((cx - hw + rc + rc * math.cos(math.radians(a)),
                    cy - hh + rc + rc * math.sin(math.radians(a))))
    for a in range(270, 361, 9):
        pts.append((cx + hw - rc + rc * math.cos(math.radians(a)),
                    cy - hh + rc + rc * math.sin(math.radians(a))))
    pts += [(cx + hw, cy + hh * 0.12),
            (cx + hw * 0.5, cy + hh * 0.66),
            (cx, cy + hh),
            (cx - hw * 0.5, cy + hh * 0.66),
            (cx - hw, cy + hh * 0.12)]
    return pts


def build(shape, transparent, scale):
    bg = (0, 0, 0, 0) if transparent else WHITE
    canvas = Image.new('RGBA', (SIZE, SIZE), bg)
    c = SIZE / 2
    paste_p(canvas, c - 0.02 * SIZE * scale, c - 0.04 * SIZE * scale, int(SIZE * 0.70 * scale))
    d = ImageDraw.Draw(canvas)
    bx, by = c + 0.21 * SIZE * scale, c + 0.22 * SIZE * scale
    rb = 0.185 * SIZE * scale
    ring = rb + 0.024 * SIZE * scale
    if shape == 'circle':
        d.ellipse([bx - ring, by - ring, bx + ring, by + ring], fill=WHITE)
        d.ellipse([bx - rb, by - rb, bx + rb, by + rb], fill=TEAL + (255,))
        draw_check(d, bx, by, rb, rb * 0.22)
    else:
        d.polygon(shield(bx, by, 2 * ring, 2.2 * ring), fill=WHITE)
        d.polygon(shield(bx, by, 2 * rb, 2.2 * rb), fill=PURPLE + (255,))
        draw_check(d, bx, by - 0.04 * rb, rb, rb * 0.22)
    return canvas


def emit(name, shape):
    build(shape, False, 1.0).save(f"/tmp/{name}_icon.png")
    build(shape, True, 0.66).save(f"/tmp/{name}_icon_fg.png")


emit('enforce', 'shield')
emit('pay', 'circle')
print("done:", FONT_PATH)
