#!/usr/bin/env python3
import sys
from copy import deepcopy
from pathlib import Path

from fontTools.ttLib import TTFont


def iter_bounds(glyf):
    for glyph_name in glyf.keys():
        glyph = glyf[glyph_name]
        if getattr(glyph, "numberOfContours", 0) == 0:
            continue
        if not hasattr(glyph, "xMin"):
            glyph.recalcBounds(glyf)
        yield glyph.xMin, glyph.yMin, glyph.xMax, glyph.yMax


def shift_glyph_y(glyph, glyf, dy):
    if dy == 0 or getattr(glyph, "numberOfContours", 0) == 0:
        return

    if glyph.isComposite():
        for component in glyph.components:
            component.y += dy
    else:
        coordinates, _, _ = glyph.getCoordinates(glyf)
        for i in range(len(coordinates)):
            coordinates[i] = (coordinates[i][0], coordinates[i][1] + dy)
        glyph.coordinates = coordinates

    glyph.recalcBounds(glyf)


def unicode_cmap(font):
    result = {}
    for table in font["cmap"].tables:
        if table.isUnicode():
            result.update(table.cmap)
    return result


def copy_missing_glyphs(font, fallback_font):
    if fallback_font is None:
        return

    source_cmap = unicode_cmap(fallback_font)
    target_cmap = unicode_cmap(font)
    missing_codepoints = sorted(set(source_cmap) - set(target_cmap))
    if not missing_codepoints:
        return

    source_glyf = fallback_font["glyf"]
    target_glyf = font["glyf"]
    source_hmtx = fallback_font["hmtx"].metrics
    target_hmtx = font["hmtx"].metrics
    glyph_order = font.getGlyphOrder()

    for codepoint in missing_codepoints:
        source_name = source_cmap[codepoint]
        target_name = f"uni{codepoint:04X}"

        if target_name not in target_glyf.glyphs:
            target_glyf.glyphs[target_name] = deepcopy(source_glyf[source_name])
            glyph_order.append(target_name)

        target_hmtx[target_name] = source_hmtx.get(source_name, (1000, 0))

        for table in font["cmap"].tables:
            if table.isUnicode():
                table.cmap[codepoint] = target_name

    font.setGlyphOrder(glyph_order)
    font["maxp"].numGlyphs = len(glyph_order)


def fix_font(path, fallback_font=None):
    font = TTFont(path)
    copy_missing_glyphs(font, fallback_font)
    glyf = font["glyf"]

    bounds = list(iter_bounds(glyf))
    if not bounds:
        return

    min_y = min(bound[1] for bound in bounds)
    dy = -min_y if min_y < 0 else 0

    if dy:
        for glyph_name in glyf.keys():
            shift_glyph_y(glyf[glyph_name], glyf, dy)

    bounds = list(iter_bounds(glyf))
    font["head"].xMin = min(bound[0] for bound in bounds)
    font["head"].yMin = min(bound[1] for bound in bounds)
    font["head"].xMax = max(bound[2] for bound in bounds)
    font["head"].yMax = max(bound[3] for bound in bounds)

    font["hhea"].ascent = 1000
    font["hhea"].descent = 0
    font["hhea"].lineGap = 0

    os2 = font["OS/2"]
    os2.sTypoAscender = 1000
    os2.sTypoDescender = 0
    os2.sTypoLineGap = 0
    os2.usWinAscent = 1000
    os2.usWinDescent = 0

    font.save(path)


def main():
    args = sys.argv[1:]
    fallback_font = None

    if "--fallback-font" in args:
        index = args.index("--fallback-font")
        try:
            fallback_font = TTFont(args[index + 1])
        except IndexError:
            print("missing value for --fallback-font", file=sys.stderr)
            return 1
        del args[index : index + 2]

    if not args:
        print(
            "usage: fix_ttf_metrics.py [--fallback-font base.ttf] <font.ttf> [...]",
            file=sys.stderr,
        )
        return 1

    for arg in args:
        fix_font(Path(arg), fallback_font)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
