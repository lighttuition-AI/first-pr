from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
PURPLE = (124, 108, 248)   # #7C6CF8
TEAL = (0, 216, 214)       # #00D8D6

# --- diagonal (135°, top-left -> bottom-right) purple->teal gradient ---
try:
    import numpy as np
    yy, xx = np.mgrid[0:SIZE, 0:SIZE]
    t = (xx + yy) / (2 * (SIZE - 1))
    r = (PURPLE[0] + (TEAL[0] - PURPLE[0]) * t).astype('uint8')
    g = (PURPLE[1] + (TEAL[1] - PURPLE[1]) * t).astype('uint8')
    b = (PURPLE[2] + (TEAL[2] - PURPLE[2]) * t).astype('uint8')
    grad = Image.fromarray(np.dstack([r, g, b]), 'RGB').convert('RGBA')
except Exception:
    grad = Image.new('RGB', (SIZE, SIZE))
    px = grad.load()
    for y in range(SIZE):
        for x in range(SIZE):
            t = (x + y) / (2 * (SIZE - 1))
            px[x, y] = (int(PURPLE[0] + (TEAL[0] - PURPLE[0]) * t),
                        int(PURPLE[1] + (TEAL[1] - PURPLE[1]) * t),
                        int(PURPLE[2] + (TEAL[2] - PURPLE[2]) * t))
    grad = grad.convert('RGBA')

# --- pick the heaviest sans-serif available ---
CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Black.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial Black.ttf",
]
FONT_PATH = None
for c in CANDIDATES:
    try:
        ImageFont.truetype(c, 100)
        FONT_PATH = c
        break
    except Exception:
        continue
print("font:", FONT_PATH)


def render_p(font_frac, transparent):
    """White (or transparent) canvas with a centred gradient 'P'."""
    bg = (0, 0, 0, 0) if transparent else (255, 255, 255, 255)
    base = Image.new('RGBA', (SIZE, SIZE), bg)
    mask = Image.new('L', (SIZE, SIZE), 0)
    d = ImageDraw.Draw(mask)
    font = ImageFont.truetype(FONT_PATH, int(SIZE * font_frac))
    l, t, r, b = d.textbbox((0, 0), "P", font=font)
    x = (SIZE - (r - l)) // 2 - l
    y = (SIZE - (b - t)) // 2 - t
    d.text((x, y), "P", fill=255, font=font)
    base.paste(grad, (0, 0), mask)
    return base


# Legacy / iOS master: white background, big gradient P.
render_p(0.74, transparent=False).save("/tmp/hpark_icon.png")
# Android adaptive foreground: transparent, P sized for the inner safe zone.
render_p(0.52, transparent=True).save("/tmp/hpark_icon_fg.png")
print("done")
