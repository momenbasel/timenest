"""Generate the GitHub social preview image (1280 x 640).

Run once, then upload the resulting PNG under Repo Settings -> Social preview.

Usage:
    python3 docs/press/social-preview.py
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parent.parent / "social-preview.png"

W, H = 1280, 640

# Brand palette (matches the web UI Tailwind config).
BG0 = (5, 7, 13)          # ink-950
BG1 = (12, 15, 23)         # ink-900
ACCENT = (56, 189, 248)    # accent-500 (sky-400)
TEXT = (245, 246, 248)     # ink-50
DIM = (153, 163, 183)      # ink-300
DIMMER = (111, 122, 147)   # ink-400


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/SFNSDisplay-Bold.otf" if bold else "/System/Library/Fonts/SFNSDisplay.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in candidates:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


img = Image.new("RGB", (W, H), BG0)
draw = ImageDraw.Draw(img)

# Diagonal gradient panel (cheap imitation using alpha blending).
panel = Image.new("RGB", (W, H), BG1)
mask = Image.new("L", (W, H))
mdraw = ImageDraw.Draw(mask)
for y in range(H):
    alpha = int(255 * (1 - y / H) * 0.6)
    mdraw.line([(0, y), (W, y)], fill=alpha)
img.paste(panel, (0, 0), mask)

# Accent glow bar top-left.
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
gdraw = ImageDraw.Draw(glow)
for r in range(600, 0, -20):
    alpha = int(40 * (600 - r) / 600)
    gdraw.ellipse(
        [(-200 - r, -200 - r), (-200 + r, -200 + r)],
        fill=(*ACCENT, alpha),
    )
img.paste(glow, (0, 0), glow)

# Clock icon (circle + hand).
cx, cy, radius = 150, 150, 56
draw.ellipse(
    [(cx - radius, cy - radius), (cx + radius, cy + radius)],
    outline=ACCENT, width=6,
)
draw.line([(cx, cy), (cx, cy - radius + 14)], fill=ACCENT, width=6)
draw.line([(cx, cy), (cx + radius - 24, cy)], fill=ACCENT, width=6)

# Headline.
title_font = load_font(128, bold=True)
sub_font = load_font(38)
tag_font = load_font(26)

draw.text((80, 240), "TimeNest", font=title_font, fill=TEXT)

tagline = "Network Time Machine for every Mac on your LAN."
draw.text((80, 400), tagline, font=sub_font, fill=DIM)

features = "Mac mini  -  Raspberry Pi  -  any Linux home server  -  zero cables"
draw.text((80, 470), features, font=tag_font, fill=DIMMER)

# Bottom bar with repo URL + stack chips.
draw.rectangle([(0, H - 70), (W, H)], fill=(0, 0, 0))
footer_font = load_font(22)
draw.text((80, H - 48), "github.com/momenbasel/timenest", font=footer_font, fill=TEXT)

chips = ["Samba 4", "vfs_fruit", "Avahi", "FastAPI", "Docker"]
x = W - 80
for chip in reversed(chips):
    bbox = draw.textbbox((0, 0), chip, font=footer_font)
    w = bbox[2] - bbox[0]
    x -= w + 28
    draw.rounded_rectangle(
        [(x - 12, H - 52), (x + w + 12, H - 22)],
        radius=10,
        outline=ACCENT, width=2,
    )
    draw.text((x, H - 48), chip, font=footer_font, fill=ACCENT)
    x -= 4

img.save(OUT, "PNG", optimize=True)
print(f"wrote {OUT} ({OUT.stat().st_size // 1024} KB)")
