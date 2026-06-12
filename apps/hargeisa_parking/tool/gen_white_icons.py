"""HPark app icons v3 — white bg + gradient "P", purple badges (checkmark circle
for Pay, shield for Enforce). Supersampled 3x for clean anti-aliased edges."""
import math
from PIL import Image, ImageDraw, ImageFont

OUT = 1024
SS = 3
W = OUT * SS
PURPLE = (124, 108, 248)
TEAL = (0, 216, 214)
WHITE = (255, 255, 255, 255)
FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Black.ttf"


def vgrad(y0, h):
    col = Image.new('RGB', (1, W))
    cp = col.load()
    for y in range(W):
        t = (y - y0) / h
        t = 0.0 if t < 0 else (1.0 if t > 1 else t)
        cp[0, y] = (int(PURPLE[0] + (TEAL[0] - PURPLE[0]) * t),
                    int(PURPLE[1] + (TEAL[1] - PURPLE[1]) * t),
                    int(PURPLE[2] + (TEAL[2] - PURPLE[2]) * t))
    return col.resize((W, W)).convert('RGBA')


def paste_p(canvas, cx, cy, font_size):
    mask = Image.new('L', (W, W), 0)
    d = ImageDraw.Draw(mask)
    font = ImageFont.truetype(FONT_PATH, font_size)
    l, t, r, b = d.textbbox((0, 0), "P", font=font)
    d.text((cx - (r - l) / 2 - l, cy - (b - t) / 2 - t), "P", fill=255, font=font)
    bb = mask.getbbox()
    canvas.paste(vgrad(bb[1], bb[3] - bb[1]), (0, 0), mask)


def check(d, bx, by, rb):
    width = rb * 0.22
    pts = [(bx - 0.36 * rb, by + 0.02 * rb),
           (bx - 0.10 * rb, by + 0.28 * rb),
           (bx + 0.40 * rb, by - 0.30 * rb)]
    d.line(pts, fill=WHITE, width=int(width), joint='curve')
    rc = width / 2
    for px, py in (pts[0], pts[2]):
        d.ellipse([px - rc, py - rc, px + rc, py + rc], fill=WHITE)


def shield_pts(cx, cy, w, h):
    """Clean, perfectly symmetric heraldic shield: flat rounded top, straight
    shoulders, smooth bezier curve to a centred point. Right half is built then
    mirrored, so the two sides match exactly."""
    hw, hh = w / 2, h / 2
    r = w * 0.16
    right = [(cx, cy - hh), (cx + hw - r, cy - hh)]
    for a in range(270, 361, 3):  # top-right rounded corner
        right.append((cx + hw - r + r * math.cos(math.radians(a)),
                      cy - hh + r + r * math.sin(math.radians(a))))
    sh = cy - hh + h * 0.46
    right.append((cx + hw, sh))               # straight shoulder
    p0, p1, p2 = (cx + hw, sh), (cx + hw, cy + hh * 0.55), (cx, cy + hh)
    for i in range(1, 21):                     # quadratic bezier to the point
        t = i / 20
        right.append(((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
                      (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]))
    left = [(2 * cx - x, y) for (x, y) in reversed(right)][1:-1]
    return right + left


def build(shape, transparent):
    canvas = Image.new('RGBA', (W, W), (0, 0, 0, 0) if transparent else WHITE)
    c = W / 2
    paste_p(canvas, c - 0.02 * W, c - 0.04 * W, int(W * 0.70))
    d = ImageDraw.Draw(canvas)
    bx, by = c + 0.21 * W, c + 0.22 * W
    rb = 0.185 * W
    ring = rb + 0.024 * W
    if shape == 'circle':
        d.ellipse([bx - ring, by - ring, bx + ring, by + ring], fill=WHITE)
        d.ellipse([bx - rb, by - rb, bx + rb, by + rb], fill=PURPLE + (255,))
        check(d, bx, by, rb)
    else:
        d.polygon(shield_pts(bx, by, 2 * ring, 2.3 * ring), fill=WHITE)
        d.polygon(shield_pts(bx, by, 2 * rb, 2.3 * rb), fill=PURPLE + (255,))
        check(d, bx, by - 0.02 * rb, rb)
    return canvas


def emit(name, shape):
    build(shape, False).resize((OUT, OUT), Image.LANCZOS).save(f"/tmp/{name}_icon.png")
    full = build(shape, True)
    s = int(W * 0.66)
    small = full.resize((s, s), Image.LANCZOS)
    fg = Image.new('RGBA', (W, W), (0, 0, 0, 0))
    fg.paste(small, ((W - s) // 2, (W - s) // 2), small)
    fg.resize((OUT, OUT), Image.LANCZOS).save(f"/tmp/{name}_icon_fg.png")


emit('enforce', 'shield')
emit('pay', 'circle')
print('done')
