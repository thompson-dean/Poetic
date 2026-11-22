#!/usr/bin/env python3
"""Compose Poetic App Store frames (1320x2868, 6.9") from raw simulator shots.

Usage: compose_screenshots.py RAW_DIR OUT_DIR

House style (from the original Poetic listing): black background, big white
Bitter slab-serif captions, large phones with a silver frame. The first
frame is the hero: "Read. Save. Share. Poetry." with one big tilted phone.
Bitter (OFL) lives in Tools/fonts.
"""
import os
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1320, 2868
BG = (0, 0, 0)
WHITE = (250, 250, 250)
FONT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fonts", "Bitter.ttf")


def bitter(size, weight="SemiBold"):
    f = ImageFont.truetype(FONT, size)
    f.set_variation_by_name(weight)
    return f


# ---------------------------------------------------------------- phone

SCREEN_R = 150


def phone(shot_path):
    """RGBA phone at native scale: polished steel band, black bezel."""
    shot = Image.open(shot_path).convert("RGB")
    sw, sh = shot.size
    band, bezel = 14, 24
    edge = band + bezel
    pw, ph = sw + 2 * edge, sh + 2 * edge
    k = 2  # supersample for smooth curves
    img = Image.new("RGBA", (pw * k, ph * k), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = (SCREEN_R + edge) * k
    d.rounded_rectangle([0, 0, pw * k - 1, ph * k - 1], radius=r, fill=(206, 206, 212, 255))
    d.rounded_rectangle([5 * k, 5 * k, pw * k - 5 * k, ph * k - 5 * k], radius=r - 5 * k, fill=(120, 120, 126, 255))
    d.rounded_rectangle([9 * k, 9 * k, pw * k - 9 * k, ph * k - 9 * k], radius=r - 9 * k, fill=(176, 176, 182, 255))
    d.rounded_rectangle([band * k, band * k, pw * k - band * k, ph * k - band * k],
                        radius=r - band * k, fill=(8, 8, 9, 255))
    img = img.resize((pw, ph), Image.LANCZOS)

    mask = Image.new("L", (sw * k, sh * k), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw * k - 1, sh * k - 1], radius=SCREEN_R * k, fill=255)
    mask = mask.resize((sw, sh), Image.LANCZOS)
    img.paste(shot, (edge, edge), mask)

    d2 = ImageDraw.Draw(img)
    x0, x1, y0, y1 = edge + 474, edge + 845, edge + 42, edge + 150
    d2.rounded_rectangle([x0, y0, x1, y1], radius=(y1 - y0) // 2, fill=(0, 0, 0, 255))
    return img


def scaled(img, scale):
    return img.resize((int(img.width * scale), int(img.height * scale)), Image.LANCZOS)


def place(canvas, img, x, y, angle=0, glow=True):
    if angle:
        img = img.rotate(angle, expand=True, resample=Image.BICUBIC)
    if glow:
        # A faint cool halo so the steel frame lifts off pure black.
        alpha = img.split()[3].point(lambda a: int(a * 0.10))
        tint = Image.new("RGBA", img.size, (150, 140, 200, 255))
        tint.putalpha(alpha)
        pad = 120
        holder = Image.new("RGBA", (img.width + pad * 2, img.height + pad * 2), (0, 0, 0, 0))
        holder.paste(tint, (pad, pad), tint)
        holder = holder.filter(ImageFilter.GaussianBlur(60))
        canvas.paste(holder, (int(x) - pad, int(y) - pad), holder)
    canvas.paste(img, (int(x), int(y)), img)


# ----------------------------------------------------------------- text

def centered(d, lines, font, y, x_center=W / 2, gap=1.13):
    for line in lines:
        w = d.textlength(line, font=font)
        d.text((x_center - w / 2, y), line, font=font, fill=WHITE)
        y += int(font.size * gap)
    return y


def caption_top(canvas, lines, size=124):
    d = ImageDraw.Draw(canvas)
    return centered(d, lines, bitter(size), 150)


# --------------------------------------------------------------- frames

def hero(raw, shot, out):
    """Words top-left, one large tilted phone sweeping in from the lower
    right and running off the edges."""
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)
    f = bitter(250, "SemiBold")
    y = 190
    for word in ["Read.", "Save.", "Share.", "Poetry."]:
        d.text((150, y), word, font=f, fill=WHITE)
        y += 262
    p = scaled(phone(os.path.join(raw, shot)), 0.86)
    rotated = p.rotate(-30, expand=True, resample=Image.BICUBIC)
    cx, cy = 1090, 2330
    place(canvas, rotated, cx - rotated.width / 2, cy - rotated.height / 2, glow=False)
    canvas.save(out, "PNG")


def single(raw, shot, out, lines):
    canvas = Image.new("RGB", (W, H), BG)
    bottom = caption_top(canvas, lines)
    p = phone(os.path.join(raw, shot))
    top = bottom + 120
    p = scaled(p, (H - top - 110) / p.height)
    place(canvas, p, (W - p.width) / 2, top)
    canvas.save(out, "PNG")


def themes(raw, shots, out, lines):
    canvas = Image.new("RGB", (W, H), BG)
    bottom = caption_top(canvas, lines)
    side_l, side_r = (scaled(phone(os.path.join(raw, s)), 0.52) for s in (shots[0], shots[2]))
    center = scaled(phone(os.path.join(raw, shots[1])), 0.64)
    top = bottom + 140
    place(canvas, side_l, -150, top + 200, angle=7)
    place(canvas, side_r, W - side_r.width + 70, top + 200, angle=-7)
    place(canvas, center, (W - center.width) / 2, top)
    canvas.save(out, "PNG")


def pair(raw, shots, out, lines):
    canvas = Image.new("RGB", (W, H), BG)
    bottom = caption_top(canvas, lines)
    a, b = (scaled(phone(os.path.join(raw, s)), 0.60) for s in shots)
    top = bottom + 110
    place(canvas, a, W / 2 - a.width + 40, top, angle=5)
    place(canvas, b, W / 2 - 40, top + 150, angle=-5)
    canvas.save(out, "PNG")


def main(raw, out):
    os.makedirs(out, exist_ok=True)
    o = lambda n: os.path.join(out, n)
    hero(raw, "detail-dark.png", o("01-hero.png"))
    pair(raw, ["widget-midnight-dark.png", "widget-sepia-light.png"], o("02-widgets.png"),
         ["A poem on your", "Home Screen,", "every morning."])
    themes(raw, ["detail-sage-light.png", "detail-midnight-dark.png", "detail-rose-dark.png"],
           o("03-themes.png"), ["Read in the light", "that suits you."])
    single(raw, "home-dark.png", o("04-todays-poem.png"), ["A new poem,", "every day."])
    single(raw, "favorites-dark.png", o("05-favorites.png"),
           ["Save your favorite", "poems and share", "with your friends."])
    single(raw, "quotes-dark.png", o("06-quotes.png"), ["Keep the lines", "that move you."])
    single(raw, "explore-dark.png", o("07-explore.png"), ["3,800+ poems from", "137 classic poets."])
    print("wrote", len([f for f in os.listdir(out) if f.endswith(".png")]), "frames to", out)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(sys.argv[1], sys.argv[2])
