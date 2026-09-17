#!/usr/bin/env python3
"""Generate gold Paladin chrome textures (transparent PNG) for LumiereUI."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parents[1] / "LumiereUI" / "Media"
OUT.mkdir(parents=True, exist_ok=True)

GOLD = (232, 186, 74, 255)
GOLD_HI = (255, 236, 170, 255)
GOLD_LO = (140, 96, 28, 255)
HALO = (255, 214, 110, 90)


def save(img: Image.Image, name: str) -> None:
    path = OUT / name
    img.save(path, "PNG")
    print(f"wrote {path} {img.size}")


def circle(draw: ImageDraw.ImageDraw, cx, cy, r, fill):
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=fill)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def make_crest(size: int = 256) -> Image.Image:
    scale = 2
    s = size * scale
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    glow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    cx = cy = s / 2
    circle(gdraw, cx, cy, s * 0.42, HALO)
    circle(gdraw, cx, cy, s * 0.28, (255, 230, 150, 70))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=s * 0.06))

    overlay = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)

    # Outer ring
    r_o, r_i = s * 0.46, s * 0.40
    d.ellipse((cx - r_o, cy - r_o, cx + r_o, cy + r_o), outline=GOLD_LO, width=int(s * 0.035))
    d.ellipse((cx - r_i, cy - r_i, cx + r_i, cy + r_i), outline=GOLD_HI, width=int(s * 0.018))

    def flared_arm(angle_deg: float) -> None:
        ang = math.radians(angle_deg)
        length = s * 0.34
        base = s * 0.055
        flare = s * 0.13
        tip_w = s * 0.16
        # Local coords: +y is out along the arm
        pts_local = [
            (-base, s * 0.04),
            (base, s * 0.04),
            (flare, length * 0.62),
            (tip_w, length * 0.78),
            (0, length),
            (-tip_w, length * 0.78),
            (-flare, length * 0.62),
        ]
        ca, sa = math.cos(ang), math.sin(ang)
        pts = []
        for x, y in pts_local:
            rx = cx + x * ca - y * sa
            ry = cy + x * sa + y * ca
            pts.append((rx, ry))
        d.polygon(pts, fill=GOLD)
        d.line(pts + [pts[0]], fill=GOLD_LO, width=max(2, s // 80))

    for a in (0, 90, 180, 270):
        flared_arm(a)

    # Center diamond / holy sun
    diamond = s * 0.11
    d.polygon(
        [(cx, cy - diamond), (cx + diamond, cy), (cx, cy + diamond), (cx - diamond, cy)],
        fill=GOLD_HI,
        outline=GOLD_LO,
    )
    circle(d, cx, cy, s * 0.035, (255, 252, 230, 255))

    # Cardinal jewels
    for a in (0, 90, 180, 270):
        rad = math.radians(a)
        jx = cx + math.sin(rad) * s * 0.43
        jy = cy - math.cos(rad) * s * 0.43
        jr = s * 0.028
        d.ellipse((jx - jr, jy - jr, jx + jr, jy + jr), fill=GOLD_HI, outline=GOLD_LO)

    composed = Image.alpha_composite(glow, overlay)
    composed = composed.resize((size, size), Image.Resampling.LANCZOS)
    return composed


def make_ring(size: int = 256) -> Image.Image:
    scale = 2
    s = size * scale
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = s / 2
    outer, inner = s * 0.495, s * 0.42
    # Draw ring as many thin ellipses for a gradient
    steps = 14
    for i in range(steps):
        t = i / (steps - 1)
        r = outer - (outer - inner) * t
        col = lerp(GOLD_LO, GOLD_HI, 0.15 + 0.7 * math.sin(t * math.pi))
        w = max(2, int(s * 0.012))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), outline=col, width=w)

    # Filigree ticks
    for i in range(12):
        ang = math.radians(i * 30 - 90)
        thick = s * (0.055 if i % 3 == 0 else 0.03)
        r1, r2 = inner - s * 0.01, outer + s * 0.002
        x1 = cx + math.cos(ang) * r1
        y1 = cy + math.sin(ang) * r1
        x2 = cx + math.cos(ang) * r2
        y2 = cy + math.sin(ang) * r2
        d.line((x1, y1, x2, y2), fill=GOLD_HI if i % 3 == 0 else GOLD, width=int(thick * 0.35))

    img = img.filter(ImageFilter.GaussianBlur(radius=0.6))
    return img.resize((size, size), Image.Resampling.LANCZOS)


def make_button_border(size: int = 64) -> Image.Image:
    scale = 4
    s = size * scale
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    pad = int(s * 0.04)
    rad = int(s * 0.12)
    # outer
    d.rounded_rectangle((pad, pad, s - pad, s - pad), radius=rad, outline=GOLD_LO, width=int(s * 0.08))
    d.rounded_rectangle(
        (pad + int(s * 0.05), pad + int(s * 0.05), s - pad - int(s * 0.05), s - pad - int(s * 0.05)),
        radius=max(2, rad - 4),
        outline=GOLD_HI,
        width=int(s * 0.035),
    )
    # corner diamonds
    for x, y in ((pad + rad, pad + rad), (s - pad - rad, pad + rad), (pad + rad, s - pad - rad), (s - pad - rad, s - pad - rad)):
        r = s * 0.04
        d.polygon([(x, y - r), (x + r, y), (x, y + r), (x - r, y)], fill=GOLD_HI)
    return img.resize((size, size), Image.Resampling.LANCZOS)


def make_glow(size: int = 128) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = size / 2
    for i, alpha in enumerate((90, 50, 25, 10)):
        r = size * (0.48 - i * 0.08)
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(255, 214, 110, alpha))
    return img.filter(ImageFilter.GaussianBlur(radius=size * 0.08))


def make_corner(size: int = 64) -> Image.Image:
    scale = 4
    s = size * scale
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.arc((-s * 0.15, -s * 0.15, s * 1.05, s * 1.05), start=180, end=270, fill=GOLD, width=int(s * 0.12))
    d.arc((int(s * 0.08), int(s * 0.08), s * 0.95, s * 0.95), start=180, end=270, fill=GOLD_HI, width=int(s * 0.045))
    d.polygon([(s * 0.08, s * 0.08), (s * 0.38, s * 0.08), (s * 0.08, s * 0.38)], fill=GOLD)
    return img.resize((size, size), Image.Resampling.LANCZOS)


def main() -> None:
    save(make_crest(), "Crest.png")
    save(make_ring(), "Ring.png")
    save(make_button_border(), "ButtonBorder.png")
    save(make_glow(), "Glow.png")
    save(make_corner(), "Corner.png")


if __name__ == "__main__":
    main()
