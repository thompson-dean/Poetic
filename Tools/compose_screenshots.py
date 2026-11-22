#!/usr/bin/env python3
"""Compose App Store marketing frames (1320x2868) from raw simulator shots."""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

S = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(S, "raw")
OUT = os.path.join(S, "out")
os.makedirs(OUT, exist_ok=True)

W, H = 1320, 2868
BG = (5, 5, 5)
CAPTION_COLOR = (245, 245, 245)

def face(path, size, ttc_name=None, variation=None):
    if ttc_name:
        for i in range(12):
            try:
                f = ImageFont.truetype(path, size, index=i)
            except Exception:
                break
            if f.getname()[1].lower() == ttc_name.lower():
                return f
        raise RuntimeError(f"face {ttc_name} not found in {path}")
    f = ImageFont.truetype(path, size)
    if variation:
        f.set_variation_by_name(variation)
    return f

def serif(size, weight="Bold"):
    return face("/System/Library/Fonts/NewYork.ttf", size, variation=weight)

def sans(size, weight="Bold"):
    return face("/System/Library/Fonts/HelveticaNeue.ttc", size, ttc_name=weight)

BEZEL = 34            # bezel thickness in px
SCREEN_R = 150        # screen corner radius at native scale
OUTLINE = (58, 58, 60)

def phone(shot_path):
    """Return an RGBA phone image at native scale (1320+2*BEZEL wide)."""
    shot = Image.open(shot_path).convert("RGB")
    sw, sh = shot.size
    # rounded screen mask (supersampled for clean edges)
    mask = Image.new("L", (sw * 2, sh * 2), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, sw * 2 - 1, sh * 2 - 1], radius=SCREEN_R * 2, fill=255)
    mask = mask.resize((sw, sh), Image.LANCZOS)

    pw, ph = sw + 2 * BEZEL, sh + 2 * BEZEL
    img = Image.new("RGBA", (pw * 2, ph * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, pw * 2 - 1, ph * 2 - 1],
                        radius=(SCREEN_R + BEZEL) * 2,
                        fill=(16, 16, 18, 255), outline=OUTLINE, width=7)
    img = img.resize((pw, ph), Image.LANCZOS)
    img.paste(shot, (BEZEL, BEZEL), mask)
    # dynamic island (matches the real cutout position on the 6.9" panel)
    d2 = ImageDraw.Draw(img)
    ix0, ix1 = BEZEL + 474, BEZEL + 845
    iy0, iy1 = BEZEL + 42, BEZEL + 150
    d2.rounded_rectangle([ix0, iy0, ix1, iy1], radius=(iy1 - iy0) // 2,
                         fill=(0, 0, 0, 255))
    return img

def draw_center(d, lines, font, y, fill=CAPTION_COLOR, line_gap=1.22):
    for line in lines:
        w = d.textlength(line, font=font)
        d.text(((W - w) / 2, y), line, font=font, fill=fill)
        y += int(font.size * line_gap)
    return y

def standard(shot, caption_lines, out_name, caption_size=72):
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)
    f = sans(caption_size, "Bold")
    n = len(caption_lines)
    text_h = int(caption_size * 1.22) * n
    zone_top, zone_bottom = 130, 470
    y = zone_top + (zone_bottom - zone_top - text_h) // 2
    draw_center(d, caption_lines, f, y)

    ph_img = phone(os.path.join(RAW, shot))
    avail_h = H - zone_bottom - 110
    scale = avail_h / ph_img.height
    ph_scaled = ph_img.resize(
        (int(ph_img.width * scale), int(ph_img.height * scale)), Image.LANCZOS)
    canvas.paste(ph_scaled, ((W - ph_scaled.width) // 2, zone_bottom),
                 ph_scaled)
    canvas.save(os.path.join(OUT, out_name), "PNG")
    print("wrote", out_name)

def hero(shot, out_name):
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)
    f_big = serif(178, "Bold")
    y = 150
    for line in ["Read.", "Save.", "Share.", "Poetry."]:
        d.text((110, y), line, font=f_big, fill=CAPTION_COLOR)
        y += 212

    ph_img = phone(os.path.join(RAW, shot))
    scale = 0.52
    ph_scaled = ph_img.resize(
        (int(ph_img.width * scale), int(ph_img.height * scale)), Image.LANCZOS)
    rotated = ph_scaled.rotate(9, expand=True, resample=Image.BICUBIC)
    # soft shadow
    shadow = Image.new("RGBA", rotated.size, (0, 0, 0, 0))
    alpha = rotated.split()[3].point(lambda a: int(a * 0.55))
    shadow.putalpha(alpha)
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    px = (W - rotated.width) // 2 + 140
    py = 950
    canvas.paste(shadow, (px + 18, py + 30), shadow)
    canvas.paste(rotated, (px, py), rotated)

    f_cap = sans(60, "Medium")
    draw_center(d, ["Access to thousands of poems", "from the greatest poets."],
                f_cap, 2665)
    canvas.save(os.path.join(OUT, out_name), "PNG")
    print("wrote", out_name)

hero("detail-dark.png", "01-hero.png")
standard("home-dark.png", ["Meet a new poet", "every day."], "02-poet-of-the-day.png")
standard("widget-home.png", ["Poetry on your", "Home Screen."], "03-widgets.png")
standard("quotes-dark.png", ["Save and share your", "favorite quotes."], "04-quotes.png")
standard("favorites-dark.png", ["Save your favorite poems and", "share with your friends."], "05-favorites.png")
standard("home-light.png", ["Light or dark mode.", "Your choice."], "06-light-dark.png")
standard("explore-dark.png", ["Explore 3,800+ poems", "from 137 classic poets."], "07-explore.png")
