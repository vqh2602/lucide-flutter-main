#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any

from fontTools.ttLib import TTFont

WEIGHTS = (100, 200, 300, 400, 500, 600)
METRIC_VERSION = 1
AREA_RATIO_TOLERANCE = 0.08
AREA_ABSOLUTE_TOLERANCE = 2500


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def parse_args() -> argparse.Namespace:
    root = repo_root()
    parser = argparse.ArgumentParser(
        description=(
            "Compare per-icon outline metrics for generated Lucide variable "
            "fonts. The failure output points at icon weights that may have "
            "been filled during SVG-to-TTF generation."
        )
    )
    parser.add_argument(
        "--update-baseline",
        action="store_true",
        help="rewrite the checked-in outline baseline from the current fonts",
    )
    parser.add_argument(
        "--codepoints",
        type=Path,
        default=root / "assets" / "codepoints.json",
    )
    parser.add_argument(
        "--font-dir",
        type=Path,
        default=root / "assets" / "build_font",
    )
    parser.add_argument(
        "--baseline",
        type=Path,
        default=root / "test" / "fixtures" / "lucide_fill_baseline.json",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    codepoints = read_codepoints(args.codepoints)
    current = build_signature(args.font_dir, codepoints)

    if args.update_baseline:
        args.baseline.parent.mkdir(parents=True, exist_ok=True)
        args.baseline.write_text(
            json.dumps(current, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        print(
            "Updated "
            f"{args.baseline.relative_to(repo_root())} with "
            f"{len(current['metrics'])} icons across {len(WEIGHTS)} weights."
        )
        return 0

    if not args.baseline.exists():
        print(
            f"Missing baseline: {args.baseline}\n"
            "Create it after visually checking the generated fonts:\n"
            "  PYTHONDONTWRITEBYTECODE=1 python3 "
            "tool/lucide/check_filled_icons.py --update-baseline",
            file=sys.stderr,
        )
        return 1

    expected = json.loads(args.baseline.read_text(encoding="utf-8"))
    failures = compare_signatures(current, expected)

    if failures:
        print("Possible filled or drifted icon outlines detected:", file=sys.stderr)
        for failure in failures[:120]:
            print(f"  - {failure}", file=sys.stderr)
        if len(failures) > 120:
            print(f"  ... and {len(failures) - 120} more", file=sys.stderr)
        print(
            "\nRegenerate fonts with tool/lucide/build_font.sh, inspect the "
            "listed icons, then refresh the baseline only after the output is "
            "known-good:\n"
            "  PYTHONDONTWRITEBYTECODE=1 python3 "
            "tool/lucide/check_filled_icons.py --update-baseline",
            file=sys.stderr,
        )
        return 1

    glyph_count = len(current["metrics"]) * len(WEIGHTS)
    print(
        f"OK: checked {glyph_count} generated icon glyphs "
        f"({len(current['metrics'])} icons x {len(WEIGHTS)} weights)."
    )
    return 0


def read_codepoints(path: Path) -> dict[str, int]:
    raw = json.loads(path.read_text(encoding="utf-8"))
    return {
        name: codepoint
        for name, codepoint in sorted(raw.items())
        if isinstance(name, str) and isinstance(codepoint, int)
    }


def build_signature(font_dir: Path, codepoints: dict[str, int]) -> dict[str, Any]:
    metrics: dict[str, Any] = {
        icon_name: {"codepoint": codepoint, "weights": {}}
        for icon_name, codepoint in codepoints.items()
    }

    for weight in WEIGHTS:
        font_path = font_dir / f"LucideVariable-w{weight}.ttf"
        if not font_path.exists():
            raise SystemExit(f"Missing font: {font_path}")

        font = TTFont(font_path)
        cmap = font.getBestCmap()
        glyf = font["glyf"]

        for icon_name, codepoint in codepoints.items():
            glyph_name = cmap.get(codepoint)
            if glyph_name is None:
                raise SystemExit(
                    f"Missing glyph for {dart_icon_name(icon_name, weight)} "
                    f"(U+{codepoint:04X}) in {font_path}"
                )
            metrics[icon_name]["weights"][str(weight)] = glyph_metrics(
                glyf,
                glyph_name,
            )

        font.close()

    return {
        "metricVersion": METRIC_VERSION,
        "weights": list(WEIGHTS),
        "metrics": metrics,
    }


def glyph_metrics(glyf: Any, glyph_name: str) -> dict[str, int]:
    glyph = glyf[glyph_name]
    if glyph.isComposite():
        glyph = deepcopy(glyph)
        glyph.expand(glyf)

    if glyph.numberOfContours <= 0:
        return {
            "contours": 0,
            "positive": 0,
            "negative": 0,
            "fillArea": 0,
            "outlineArea": 0,
        }

    coordinates = list(glyph.coordinates)
    start = 0
    signed_areas: list[float] = []

    for end in glyph.endPtsOfContours:
        points = coordinates[start : end + 1]
        start = end + 1
        area = signed_area(points)
        if abs(area) > 0.5:
            signed_areas.append(area)

    return {
        "contours": len(signed_areas),
        "positive": sum(1 for area in signed_areas if area > 0),
        "negative": sum(1 for area in signed_areas if area < 0),
        "fillArea": round_int(abs(sum(signed_areas))),
        "outlineArea": round_int(sum(abs(area) for area in signed_areas)),
    }


def signed_area(points: list[tuple[int, int]]) -> float:
    if len(points) < 3:
        return 0

    area = 0.0
    previous_x, previous_y = points[-1]
    for x, y in points:
        area += previous_x * y - x * previous_y
        previous_x, previous_y = x, y
    return area / 2.0


def round_int(value: float) -> int:
    return int(round(value))


def compare_signatures(
    current: dict[str, Any],
    expected: dict[str, Any],
) -> list[str]:
    failures: list[str] = []

    if expected.get("metricVersion") != METRIC_VERSION:
        failures.append(
            "baseline metricVersion "
            f"{expected.get('metricVersion')} != {METRIC_VERSION}"
        )
        return failures

    expected_metrics = expected.get("metrics", {})
    current_metrics = current["metrics"]

    for icon_name in sorted(set(current_metrics) - set(expected_metrics)):
        failures.append(f"{icon_name}: missing from fill baseline")

    for icon_name in sorted(set(expected_metrics) - set(current_metrics)):
        failures.append(f"{icon_name}: no longer exists in generated metrics")

    for icon_name in sorted(set(current_metrics) & set(expected_metrics)):
        expected_icon = expected_metrics[icon_name]
        current_icon = current_metrics[icon_name]

        if current_icon["codepoint"] != expected_icon["codepoint"]:
            failures.append(
                f"{icon_name}: codepoint U+{current_icon['codepoint']:04X} "
                f"!= baseline U+{expected_icon['codepoint']:04X}"
            )
            continue

        for weight in WEIGHTS:
            key = str(weight)
            actual = current_icon["weights"].get(key)
            baseline = expected_icon["weights"].get(key)
            if actual is None or baseline is None:
                failures.append(f"{dart_icon_name(icon_name, weight)}: missing metrics")
                continue

            reasons = compare_metric(actual, baseline)
            if reasons:
                failures.append(
                    f"{dart_icon_name(icon_name, weight)}: "
                    + "; ".join(reasons)
                )

    return failures


def compare_metric(actual: dict[str, int], baseline: dict[str, int]) -> list[str]:
    reasons: list[str] = []

    for key in ("contours", "positive", "negative"):
        if actual[key] != baseline[key]:
            reasons.append(f"{key} {actual[key]} != {baseline[key]}")

    for key in ("fillArea", "outlineArea"):
        delta = actual[key] - baseline[key]
        tolerance = max(
            AREA_ABSOLUTE_TOLERANCE,
            round_int(baseline[key] * AREA_RATIO_TOLERANCE),
        )
        if abs(delta) > tolerance:
            sign = "+" if delta > 0 else ""
            ratio = 0.0 if baseline[key] == 0 else (delta / baseline[key]) * 100
            reasons.append(
                f"{key} {sign}{ratio:.1f}% "
                f"({actual[key]} != {baseline[key]})"
            )

    return reasons


def dart_icon_name(icon_name: str, weight: int) -> str:
    parts = icon_name.split("-")
    camel = parts[0] + "".join(part[:1].upper() + part[1:] for part in parts[1:])
    return f"{camel}{weight}"


if __name__ == "__main__":
    sys.exit(main())
