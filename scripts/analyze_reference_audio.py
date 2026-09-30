#!/usr/bin/env python3
"""Measure Rǫdd reference tempo and pitch preservation."""

from __future__ import annotations

import argparse
import array
import json
import math
import statistics
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PACK_ROOT = ROOT / "content/prayer-packs/sigrdrifumal-west-norse-ca-1200"
DEFAULT_MANIFEST = PACK_ROOT / "reference-audio/manifest.json"


def load_samples(path: Path) -> tuple[int, list[float]]:
    with wave.open(str(path), "rb") as audio:
        if audio.getnchannels() != 1 or audio.getsampwidth() != 2:
            raise ValueError(f"expected mono 16-bit PCM: {path}")
        rate = audio.getframerate()
        values = array.array("h", audio.readframes(audio.getnframes()))
    stride = 4
    return rate // stride, [float(value) for value in values[::stride]]


def median_pitch(path: Path) -> float:
    rate, samples = load_samples(path)
    frame_size = int(rate * 0.04)
    hop = int(rate * 0.02)
    min_lag = max(1, int(rate / 350))
    max_lag = int(rate / 70)
    pitches: list[float] = []

    for start in range(0, max(0, len(samples) - frame_size), hop * 2):
        frame = samples[start:start + frame_size]
        mean = sum(frame) / len(frame)
        centered = [sample - mean for sample in frame]
        energy = sum(sample * sample for sample in centered) / len(centered)
        if energy < 250_000:
            continue
        best_lag = 0
        best_score = 0.0
        for lag in range(min_lag, min(max_lag, len(centered) - 2)):
            left = centered[:-lag]
            right = centered[lag:]
            numerator = sum(a * b for a, b in zip(left, right))
            left_energy = sum(a * a for a in left)
            right_energy = sum(b * b for b in right)
            denominator = math.sqrt(left_energy * right_energy)
            score = numerator / denominator if denominator else 0.0
            if score > best_score:
                best_score = score
                best_lag = lag
        if best_lag and best_score >= 0.55:
            pitches.append(rate / best_lag)

    if not pitches:
        raise ValueError(f"could not estimate pitch for {path}")
    return statistics.median(pitches)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", nargs="?", type=Path, default=DEFAULT_MANIFEST)
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    entries = {entry["id"]: entry for entry in manifest["entries"]}
    pairs = []

    for entry in manifest["entries"]:
        if entry["tempo"] != "teaching":
            continue
        source_id = entry["tempoDerivation"]["sourceId"]
        natural = entries[source_id]
        natural_path = PACK_ROOT / natural["file"]
        teaching_path = PACK_ROOT / entry["file"]
        natural_pitch = median_pitch(natural_path)
        teaching_pitch = median_pitch(teaching_path)
        cents = 1200 * math.log2(teaching_pitch / natural_pitch)
        duration_ratio = entry["durationSeconds"] / natural["durationSeconds"]
        pairs.append({
            "lineId": entry["lineId"],
            "style": entry["style"],
            "naturalId": source_id,
            "teachingId": entry["id"],
            "naturalMedianPitchHz": round(natural_pitch, 3),
            "teachingMedianPitchHz": round(teaching_pitch, 3),
            "pitchDifferenceCents": round(cents, 3),
            "durationRatio": round(duration_ratio, 4),
            "pitchPreserved": abs(cents) <= 80,
            "tempoVerified": 1.32 <= duration_ratio <= 1.46,
        })

    result = {
        "analysisVersion": "1.0.0",
        "manifest": args.manifest.relative_to(PACK_ROOT).as_posix(),
        "method": "Median autocorrelation pitch estimate over voiced 40 ms frames; teaching duration compared with its natural source.",
        "pitchToleranceCents": 80,
        "expectedDurationRatioRange": [1.32, 1.46],
        "pairs": pairs,
        "allPitchPreserved": all(pair["pitchPreserved"] for pair in pairs),
        "allTempoVerified": all(pair["tempoVerified"] for pair in pairs),
    }
    output = args.manifest.parent / "analysis.json"
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(
        f"Analyzed {len(pairs)} tempo pairs: "
        f"pitch_preserved={result['allPitchPreserved']} "
        f"tempo_verified={result['allTempoVerified']}"
    )
    return 0 if result["allPitchPreserved"] and result["allTempoVerified"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
