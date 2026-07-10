#!/usr/bin/env python3
import sys
from copy import deepcopy
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.ttLib.tables._g_l_y_f import Glyph

PUA_START = 0xE000
BROKEN_CONTOUR_MIN_SIZE = 250


def contour_area(points):
    area = 0
    for index, (x1, y1) in enumerate(points):
        x2, y2 = points[(index + 1) % len(points)]
        area += x1 * y2 - x2 * y1
    return area / 2


def contour_bounds(points):
    xs = [point[0] for point in points]
    ys = [point[1] for point in points]
    return min(xs), min(ys), max(xs), max(ys)


def contour_sample_point(points):
    x_min, y_min, x_max, y_max = contour_bounds(points)
    return (x_min + x_max) / 2, (y_min + y_max) / 2


def point_in_contour(point, contour_points):
    x, y = point
    inside = False
    previous_x, previous_y = contour_points[-1]

    for current_x, current_y in contour_points:
        intersects = (current_y > y) != (previous_y > y)
        if intersects:
            slope_x = (
                (previous_x - current_x)
                * (y - current_y)
                / (previous_y - current_y)
                + current_x
            )
            if x < slope_x:
                inside = not inside
        previous_x, previous_y = current_x, current_y

    return inside


def contour_contains(parent, child):
    parent_bounds = parent["bounds"]
    child_bounds = child["bounds"]

    if (
        child_bounds[0] < parent_bounds[0]
        or child_bounds[1] < parent_bounds[1]
        or child_bounds[2] > parent_bounds[2]
        or child_bounds[3] > parent_bounds[3]
    ):
        return False

    return point_in_contour(child["sample"], parent["points"])


def reverse_contour(glyph, start, end):
    glyph.coordinates[start : end + 1] = glyph.coordinates[start : end + 1][::-1]
    glyph.flags[start : end + 1] = glyph.flags[start : end + 1][::-1]


def fix_nested_contour_directions(glyph, glyf):
    if getattr(glyph, "numberOfContours", 0) <= 1 or glyph.isComposite():
        return

    coordinates, end_points, flags = glyph.getCoordinates(glyf)
    glyph.coordinates = coordinates
    glyph.endPtsOfContours = end_points
    glyph.flags = flags

    contours = []
    start = 0
    for index, end in enumerate(end_points):
        points = list(coordinates[start : end + 1])
        area = contour_area(points)
        if area == 0:
            start = end + 1
            continue

        contours.append(
            {
                "index": index,
                "start": start,
                "end": end,
                "points": points,
                "area": area,
                "bounds": contour_bounds(points),
                "sample": contour_sample_point(points),
            }
        )
        start = end + 1

    if len(contours) <= 1:
        return

    for child in contours:
        parents = [
            parent
            for parent in contours
            if parent["index"] != child["index"]
            and abs(parent["area"]) > abs(child["area"])
            and contour_contains(parent, child)
        ]
        child["parent"] = min(
            parents,
            key=lambda parent: abs(parent["area"]),
            default=None,
        )

    changed = False
    for contour in sorted(contours, key=lambda item: abs(item["area"]), reverse=True):
        parent = contour["parent"]
        if parent is None:
            continue

        if (contour["area"] > 0) == (parent["area"] > 0):
            reverse_contour(glyph, contour["start"], contour["end"])
            contour["area"] = -contour["area"]
            changed = True

    if changed:
        glyph.recalcBounds(glyf)


def iter_bounds(glyf):
    for glyph_name in glyf.keys():
        glyph = glyf[glyph_name]
        if getattr(glyph, "numberOfContours", 0) == 0:
            continue
        if not hasattr(glyph, "xMin"):
            glyph.recalcBounds(glyf)
        yield glyph.xMin, glyph.yMin, glyph.xMax, glyph.yMax


def glyph_bounds(glyph, glyf):
    if getattr(glyph, "numberOfContours", 0) == 0:
        return None
    if not hasattr(glyph, "xMin"):
        glyph.recalcBounds(glyf)
    return glyph.xMin, glyph.yMin, glyph.xMax, glyph.yMax


def transform_glyph(glyph, glyf, scale=1.0, dx=0, dy=0):
    if getattr(glyph, "numberOfContours", 0) == 0:
        return

    if glyph.isComposite():
        for component in glyph.components:
            component.x = int(round(component.x * scale + dx))
            component.y = int(round(component.y * scale + dy))
            transform = getattr(component, "transform", None)
            if scale != 1.0 and transform:
                xx, xy, yx, yy = transform
                component.transform = (
                    xx * scale,
                    xy * scale,
                    yx * scale,
                    yy * scale,
                )
    else:
        coordinates, _, _ = glyph.getCoordinates(glyf)
        for i in range(len(coordinates)):
            x, y = coordinates[i]
            coordinates[i] = (
                int(round(x * scale + dx)),
                int(round(y * scale + dy)),
            )
        glyph.coordinates = coordinates

    glyph.recalcBounds(glyf)


def has_broken_open_contours(glyph, glyf):
    if getattr(glyph, "numberOfContours", 0) == 0 or glyph.isComposite():
        return False

    coordinates, end_points, _ = glyph.getCoordinates(glyf)
    start = 0
    for end in end_points:
        points = coordinates[start : end + 1]
        start = end + 1
        if not points:
            continue

        xs = [point[0] for point in points]
        ys = [point[1] for point in points]
        width = max(xs) - min(xs)
        height = max(ys) - min(ys)

        # FontForge sometimes imports stroked open SVG paths as centerlines
        # instead of filled outlines. Those zero-area contours are effectively
        # invisible in a TTF glyph and make icons with many line segments render
        # as tiny fragments.
        if (width == 0 or height == 0) and max(width, height) >= BROKEN_CONTOUR_MIN_SIZE:
            return True

    return False


def replace_broken_imports(font, fallback_font):
    if fallback_font is None:
        return

    target_cmap = unicode_cmap(font)
    source_cmap = unicode_cmap(fallback_font)
    target_glyf = font["glyf"]
    source_glyf = fallback_font["glyf"]
    target_hmtx = font["hmtx"].metrics
    source_hmtx = fallback_font["hmtx"].metrics

    for codepoint, target_name in target_cmap.items():
        if codepoint < PUA_START or target_name not in target_glyf.glyphs:
            continue
        if codepoint not in source_cmap:
            continue

        target_glyph = target_glyf[target_name]
        if not has_broken_open_contours(target_glyph, target_glyf):
            continue

        source_name = source_cmap[codepoint]
        target_glyf.glyphs[target_name] = deepcopy(source_glyf[source_name])
        target_hmtx[target_name] = source_hmtx.get(source_name, (1000, 0))


def generated_icon_glyph_names(font):
    cmap = unicode_cmap(font)
    return {
        glyph_name
        for codepoint, glyph_name in cmap.items()
        if codepoint >= PUA_START and glyph_name in font["glyf"].glyphs
    }


def normalize_icon_glyphs(font):
    glyf = font["glyf"]
    hmtx = font["hmtx"].metrics
    units_per_em = font["head"].unitsPerEm or 1000
    oversized_target = units_per_em * 0.96

    for glyph_name in generated_icon_glyph_names(font):
        glyph = glyf[glyph_name]
        fix_nested_contour_directions(glyph, glyf)

        bounds = glyph_bounds(glyph, glyf)
        if bounds is None:
            continue

        x_min, y_min, x_max, y_max = bounds
        width = x_max - x_min
        height = y_max - y_min
        if width <= 0 or height <= 0:
            continue

        max_dim = max(width, height)
        scale = 1.0
        dx = 0

        # FontForge can import some stroked SVGs far outside the 1000-unit icon
        # box. Fit those glyphs back before centering them for Flutter.
        if max_dim > oversized_target:
            scale = oversized_target / max_dim
            scaled_width = width * scale
            dx = (units_per_em - scaled_width) / 2 - x_min * scale

        scaled_height = height * scale
        dy = (units_per_em - scaled_height) / 2 - y_min * scale
        transform_glyph(glyph, glyf, scale=scale, dx=dx, dy=dy)

        x_min, _, _, _ = glyph_bounds(glyph, glyf)
        advance_width, _ = hmtx.get(glyph_name, (units_per_em, 0))
        hmtx[glyph_name] = (advance_width, x_min)


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
    source_glyf = fallback_font["glyf"]
    target_glyf = font["glyf"]
    source_hmtx = fallback_font["hmtx"].metrics
    target_hmtx = font["hmtx"].metrics
    glyph_order = font.getGlyphOrder()

    if ".notdef" in source_glyf.glyphs:
        target_glyf.glyphs[".notdef"] = deepcopy(source_glyf[".notdef"])
        target_hmtx[".notdef"] = source_hmtx.get(".notdef", (1000, 0))
    else:
        target_glyf.glyphs[".notdef"] = Glyph()
        target_glyf.glyphs[".notdef"].numberOfContours = 0
        target_hmtx[".notdef"] = (1000, 0)

    if ".notdef" not in glyph_order:
        glyph_order.insert(0, ".notdef")

    fallback_codepoints = sorted(
        codepoint
        for codepoint in source_cmap
        if codepoint not in target_cmap or codepoint < PUA_START
    )
    if not fallback_codepoints:
        font.setGlyphOrder(glyph_order)
        font["maxp"].numGlyphs = len(glyph_order)
        return

    for codepoint in fallback_codepoints:
        source_name = source_cmap[codepoint]
        target_name = f"uni{codepoint:04X}"

        target_glyf.glyphs[target_name] = deepcopy(source_glyf[source_name])
        if target_name not in glyph_order:
            glyph_order.append(target_name)

        target_hmtx[target_name] = source_hmtx.get(source_name, (1000, 0))

        for table in font["cmap"].tables:
            if table.isUnicode():
                table.cmap[codepoint] = target_name

    font.setGlyphOrder(glyph_order)
    font["maxp"].numGlyphs = len(glyph_order)


def fix_font(path, fallback_font=None):
    font = TTFont(path)
    replace_broken_imports(font, fallback_font)
    normalize_icon_glyphs(font)
    copy_missing_glyphs(font, fallback_font)
    glyf = font["glyf"]

    bounds = list(iter_bounds(glyf))
    if not bounds:
        return

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
