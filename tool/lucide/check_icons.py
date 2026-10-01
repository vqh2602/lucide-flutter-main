#!/usr/bin/env python3
"""
Comprehensive icon quality and integrity inspection for Lucide variable fonts.

Validates all 6 weights (100, 200, 300, 400, 500, 600) against assets/lucide.ttf:
1. Missing Glyphs: Glyphs present in base font must exist in all variable weights.
2. Empty Glyphs: Glyphs must have contours > 0.
3. Missing Strokes: Detects truncated or dropped outlines (e.g. calendar-fold missing outer frame).
4. Filled Icons / Collapsed Holes: Detects when inner cutouts (like letter 'B' in 'letters',
   inner loops in 'signature', or locks/ribbons) collapse into solid black fills.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path
from fontTools.ttLib import TTFont

WEIGHTS = (100, 200, 300, 400, 500, 600)


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def get_glyph_topology(glyf, cmap: dict[int, str], cp: int) -> list[dict]:
    """Extracts contours, areas, bounding boxes, and calculates topological nesting depth.
    
    Even depth (0, 2, ...) indicates solid outer contours / islands.
    Odd depth (1, 3, ...) indicates inner cutout holes.
    """
    gname = cmap.get(cp)
    if not gname or gname not in glyf:
        return []
    g = glyf[gname]
    if g.isComposite():
        from copy import deepcopy
        g = deepcopy(g)
        g.expand(glyf)
    if getattr(g, "numberOfContours", 0) <= 0:
        return []

    coords = list(g.coordinates)
    start = 0
    contours = []
    for end in g.endPtsOfContours:
        pts = coords[start : end + 1]
        start = end + 1
        if len(pts) < 3:
            continue
        area = 0.0
        prev_x, prev_y = pts[-1]
        for x, y in pts:
            area += prev_x * y - x * prev_y
            prev_x, prev_y = x, y
        area /= 2.0
        min_x = min(p[0] for p in pts)
        max_x = max(p[0] for p in pts)
        min_y = min(p[1] for p in pts)
        max_y = max(p[1] for p in pts)
        contours.append({
            "area": area,
            "abs_area": abs(area),
            "bbox": (min_x, min_y, max_x, max_y),
        })

    # Calculate topological nesting depth for each contour
    for i, c in enumerate(contours):
        bx0, by0, bx1, by1 = c["bbox"]
        depth = 0
        for j, parent in enumerate(contours):
            if i == j:
                continue
            px0, py0, px1, py1 = parent["bbox"]
            # Contour c is inside parent contour if bounding box fits within parent
            if px0 <= bx0 + 8 and px1 >= bx1 - 8 and py0 <= by0 + 8 and py1 >= by1 - 8:
                if parent["abs_area"] > c["abs_area"] * 1.1:
                    depth += 1
        c["depth"] = depth
        c["is_hole"] = (depth % 2 == 1)

    return contours


def main() -> int:
    root = repo_root()
    base_font_path = root / "assets" / "lucide.ttf"
    codepoints_path = root / "assets" / "codepoints.json"
    font_dir = root / "assets" / "build_font"

    if not base_font_path.exists():
        print(f"❌ Missing base font: {base_font_path}", file=sys.stderr)
        return 1
    if not codepoints_path.exists():
        print(f"❌ Missing codepoints file: {codepoints_path}", file=sys.stderr)
        return 1

    with open(codepoints_path, encoding="utf-8") as f:
        codepoints = json.load(f)

    base_font = TTFont(base_font_path)
    base_cmap = base_font.getBestCmap()
    base_glyf = base_font["glyf"]

    weight_fonts: dict[int, TTFont] = {}
    weight_cmaps: dict[int, dict[int, str]] = {}
    for w in WEIGHTS:
        font_path = font_dir / f"LucideVariable-w{w}.ttf"
        if not font_path.exists():
            print(f"❌ Missing variable font: {font_path}", file=sys.stderr)
            return 1
        w_font = TTFont(font_path)
        weight_fonts[w] = w_font
        weight_cmaps[w] = w_font.getBestCmap()

    errors: list[str] = []
    warnings: list[str] = []
    checked_count = 0

    print(f"🔍 Validating icons across {len(WEIGHTS)} weights against assets/lucide.ttf...")

    for name, cp in sorted(codepoints.items()):
        if not isinstance(name, str) or not isinstance(cp, int):
            continue

        c_base = get_glyph_topology(base_glyf, base_cmap, cp)
        if not c_base:
            continue

        checked_count += 1
        base_outline = sum(c["abs_area"] for c in c_base)
        base_sig_holes = [c for c in c_base if c["is_hole"] and c["abs_area"] > 2000]
        base_major_holes = [c for c in c_base if c["is_hole"] and c["abs_area"] > 5000]

        for w in WEIGHTS:
            w_cmap = weight_cmaps[w]
            w_glyf = weight_fonts[w]["glyf"]
            gname = w_cmap.get(cp)

            if not gname or gname not in w_glyf:
                errors.append(f"{name} (U+{cp:04X}): Missing glyph in weight {w}")
                continue

            c_w = get_glyph_topology(w_glyf, w_cmap, cp)
            if not c_w:
                errors.append(f"{name} (U+{cp:04X}): Weight {w} has 0 contours (base font has {len(c_base)})")
                continue

            w_outline = sum(c["abs_area"] for c in c_w)

            # 1. Missing strokes check (weight 400 is 2.0px stroke, directly comparable to base font)
            if w == 400 and base_outline > 0:
                ratio = w_outline / base_outline
                if ratio < 0.65:
                    errors.append(
                        f"{name} (U+{cp:04X}): Missing strokes in weight 400! Outline area is only "
                        f"{ratio:.1%} of base font ({w_outline} vs {base_outline})"
                    )

                # 2. Significant hole check in weight 400 (must preserve all holes present in base font)
                w_sig_holes = [c for c in c_w if c["is_hole"] and c["abs_area"] > 500]
                if len(w_sig_holes) < len(base_sig_holes):
                    errors.append(
                        f"{name} (U+{cp:04X}): FILLED IN SOLID in weight 400! Cutout hole(s) collapsed "
                        f"(base has {len(base_sig_holes)} hole(s), w400 has only {len(w_sig_holes)})"
                    )

            # 3. Major hole check in heavy weights (w500, w600)
            # Detects collapsed holes like letter 'B' in 'letters' or 'A' in 'case-upper'
            elif w in (500, 600) and base_major_holes:
                w_major_holes = [c for c in c_w if c["is_hole"] and c["abs_area"] > 500]
                if len(w_major_holes) < len(base_major_holes):
                    errors.append(
                        f"{name} (U+{cp:04X}): FILLED IN SOLID in weight {w}! Cutout hole(s) collapsed "
                        f"(base has {len(base_major_holes)} major hole(s), w{w} has only {len(w_major_holes)})"
                    )

    print(f"📊 Checked {checked_count} icons across weights {WEIGHTS}.")

    if warnings:
        print(f"\n⚠️  {len(warnings)} warning(s):", file=sys.stderr)
        for w in warnings[:20]:
            print(f"  - {w}", file=sys.stderr)
        if len(warnings) > 20:
            print(f"  ... and {len(warnings) - 20} more", file=sys.stderr)

    if errors:
        print(f"\n❌ {len(errors)} error(s) found in icon outlines / fill status:", file=sys.stderr)
        for err in errors[:50]:
            print(f"  - {err}", file=sys.stderr)
        if len(errors) > 50:
            print(f"  ... and {len(errors) - 50} more errors", file=sys.stderr)
        print("\nFix these icons by adding them to AUTO_OUTLINE_ICONS in tool/lucide/build_font.sh", file=sys.stderr)
        return 1

    print("✅ All icons passed integrity, fill, and outline validation!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
