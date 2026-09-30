#!/usr/bin/env python3
"""Validate the Rǫdd prayer pack using only the Python standard library."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import wave
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_PACK = ROOT / "content/prayer-packs/sigrdrifumal-west-norse-ca-1200/pack.json"
SEMVER = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
IPA = re.compile(r"^/.+/$")
CONFIDENCE = {"high", "medium", "low"}
STRESS = {"primary", "secondary", "unstressed"}
RULE_CATEGORIES = {
    "profile",
    "text",
    "vowel",
    "diphthong",
    "consonant",
    "quantity",
    "stress",
    "prosody",
}


class ValidationError(Exception):
    """Raised when a prayer pack violates its contract."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def unique_ids(items: list[dict[str, Any]], label: str) -> set[str]:
    ids = [item.get("id") for item in items]
    require(all(isinstance(item_id, str) and item_id for item_id in ids), f"{label} need non-empty ids")
    require(len(ids) == len(set(ids)), f"{label} ids must be unique")
    return set(ids)


def require_keys(item: dict[str, Any], keys: set[str], label: str) -> None:
    missing = keys - item.keys()
    require(not missing, f"{label} is missing: {', '.join(sorted(missing))}")


def validate_pack(data: dict[str, Any]) -> None:
    require_keys(
        data,
        {
            "packVersion",
            "contractId",
            "work",
            "profile",
            "sourceWitness",
            "referenceAudio",
            "sources",
            "rules",
            "normalizationDecisions",
            "lexicon",
            "lines",
        },
        "pack",
    )
    require(bool(SEMVER.fullmatch(data["packVersion"])), "packVersion must be semantic x.y.z")
    require(data["contractId"] == "ON-WN-C1200-v1.0", "unexpected pronunciation contract id")
    require(data["profile"]["id"] == "west-norse-ca-1200", "unexpected profile id")

    reference_audio = data["referenceAudio"]
    require_keys(reference_audio, {"manifest", "analysis", "attribution", "styles", "tempos"}, "referenceAudio")
    require(set(reference_audio["styles"]) == {"precise", "naturalized"}, "referenceAudio needs precise and naturalized styles")
    require(set(reference_audio["tempos"]) == {"natural", "teaching"}, "referenceAudio needs natural and teaching tempos")
    for style, label in reference_audio["styles"].items():
        require_keys(label, {"label", "purpose", "limitation"}, f"referenceAudio style {style}")

    sources = data["sources"]
    rules = data["rules"]
    decisions = data["normalizationDecisions"]
    lexicon = data["lexicon"]
    lines = data["lines"]
    require(all(isinstance(group, list) for group in (sources, rules, decisions, lexicon, lines)), "pack collections must be arrays")

    source_ids = unique_ids(sources, "sources")
    rule_ids = unique_ids(rules, "rules")
    unique_ids(decisions, "normalization decisions")
    lexeme_ids = unique_ids(lexicon, "lexicon entries")
    unique_ids(lines, "lines")

    for source in sources:
        require_keys(source, {"id", "kind", "citation", "url", "accessed"}, f"source {source['id']}")
        require(source["url"].startswith("https://"), f"source {source['id']} must use https")

    for rule in rules:
        label = f"rule {rule['id']}"
        require_keys(rule, {"id", "category", "statement", "confidence", "scorable", "evidence"}, label)
        require(rule["category"] in RULE_CATEGORIES, f"{label} has unknown category")
        require(rule["confidence"] in CONFIDENCE, f"{label} has invalid confidence")
        require(isinstance(rule["scorable"], bool), f"{label} scorable must be boolean")
        require(rule["evidence"], f"{label} needs evidence")
        evidence_sources = {entry["sourceId"] for entry in rule["evidence"]}
        require(evidence_sources <= source_ids, f"{label} cites an unknown source")
        if rule["confidence"] == "high":
            require(len(evidence_sources) >= 2, f"{label} needs two independent sources")
        if rule["confidence"] == "low":
            require(not rule["scorable"], f"{label} is low-confidence and cannot be scored")

    for decision in decisions:
        label = f"normalization decision {decision['id']}"
        require_keys(decision, {"id", "selected", "alternatives", "rationale", "sourceIds"}, label)
        require(set(decision["sourceIds"]) <= source_ids, f"{label} cites an unknown source")

    for entry in lexicon:
        label = f"lexeme {entry['id']}"
        require_keys(
            entry,
            {
                "id",
                "surface",
                "normalized",
                "canonicalIpa",
                "syllables",
                "acceptedVariants",
                "confidence",
                "quantityTargets",
                "ruleIds",
                "sourceIds",
                "teachingNotes",
            },
            label,
        )
        require(bool(IPA.fullmatch(entry["canonicalIpa"])), f"{label} needs slash-delimited IPA")
        require(entry["confidence"] in CONFIDENCE, f"{label} has invalid confidence")
        require(entry["syllables"], f"{label} needs syllables")
        require(sum(syllable["stress"] == "primary" for syllable in entry["syllables"]) == 1, f"{label} needs exactly one primary stress")
        require(all(syllable["stress"] in STRESS for syllable in entry["syllables"]), f"{label} has invalid stress")
        require(set(entry["ruleIds"]) <= rule_ids, f"{label} cites an unknown rule")
        require(set(entry["sourceIds"]) <= source_ids, f"{label} cites an unknown source")
        require(len(set(entry["sourceIds"])) >= 2, f"{label} needs text and pronunciation sources")
        for variant in entry["acceptedVariants"]:
            require(bool(IPA.fullmatch(variant["ipa"])), f"{label} variant needs slash-delimited IPA")
            require(set(variant["sourceIds"]) <= source_ids, f"{label} variant cites an unknown source")

    require(len(lines) == 8, "the initial pack must contain exactly eight lines")
    require(sorted(line["order"] for line in lines) == list(range(1, 9)), "line order must be 1 through 8")
    require([line["stanza"] for line in sorted(lines, key=lambda item: item["order"])] == [3, 3, 3, 3, 4, 4, 4, 4], "lines must cover stanzas 3 and 4")
    for line in lines:
        label = f"line {line['id']}"
        require_keys(line, {"id", "order", "stanza", "editionText", "normalizedText", "tokenIds", "sourceIds"}, label)
        require(line["tokenIds"], f"{label} needs tokens")
        require(set(line["tokenIds"]) <= lexeme_ids, f"{label} references an unknown lexeme")
        require(set(line["sourceIds"]) <= source_ids, f"{label} cites an unknown source")
        require(len(set(line["sourceIds"])) >= 2, f"{label} needs manuscript and critical-edition support")


def file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def validate_reference_audio(data: dict[str, Any], pack_root: Path) -> None:
    config = data["referenceAudio"]
    resolved_root = pack_root.resolve()
    paths = {
        name: (pack_root / config[name]).resolve()
        for name in ("manifest", "analysis", "attribution")
    }
    for name, path in paths.items():
        require(path.is_relative_to(resolved_root), f"referenceAudio {name} escapes the pack")
        require(path.is_file(), f"referenceAudio {name} is missing: {path}")

    try:
        manifest = json.loads(paths["manifest"].read_text(encoding="utf-8"))
        analysis = json.loads(paths["analysis"].read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ValidationError(f"invalid reference-audio JSON: {error}") from error

    require(manifest["contentVersion"] == data["packVersion"], "audio manifest content version differs from pack")
    require(manifest["contractId"] == data["contractId"], "audio manifest contract differs from pack")
    entries = manifest.get("entries", [])
    require(len(entries) == 32, "audio manifest must contain 32 files")
    unique_ids(entries, "reference-audio entries")
    line_ids = {line["id"] for line in data["lines"]}
    expected = {
        (line_id, style, tempo)
        for line_id in line_ids
        for style in ("precise", "naturalized")
        for tempo in ("natural", "teaching")
    }
    actual = {(entry.get("lineId"), entry.get("style"), entry.get("tempo")) for entry in entries}
    require(actual == expected, "audio manifest does not cover every line, style, and tempo exactly once")

    for entry in entries:
        label = f"reference audio {entry['id']}"
        require_keys(
            entry,
            {
                "id", "lineId", "style", "tempo", "file", "sha256",
                "contentVersion", "contractId", "inputTarget", "synthesisInput",
                "synthesizedIpa", "sampleRate", "channels", "sampleWidthBits",
                "durationSeconds", "method", "assetLicense",
            },
            label,
        )
        require(entry["contentVersion"] == data["packVersion"], f"{label} has wrong content version")
        require(entry["contractId"] == data["contractId"], f"{label} has wrong contract")
        require_keys(entry["method"], {"engine", "version", "mode", "softwareLicense"}, f"{label} method")
        audio_path = (pack_root / entry["file"]).resolve()
        require(audio_path.is_relative_to(resolved_root), f"{label} escapes the pack")
        require(audio_path.is_file(), f"{label} file is missing")
        require(file_sha256(audio_path) == entry["sha256"], f"{label} checksum mismatch")
        with wave.open(str(audio_path), "rb") as audio:
            require(audio.getframerate() == entry["sampleRate"] == 22050, f"{label} sample rate mismatch")
            require(audio.getnchannels() == entry["channels"] == 1, f"{label} must be mono")
            require(audio.getsampwidth() * 8 == entry["sampleWidthBits"] == 16, f"{label} must be 16-bit PCM")
        if entry["tempo"] == "teaching":
            require_keys(entry, {"tempoDerivation"}, label)
            require_keys(
                entry["tempoDerivation"],
                {"sourceId", "method", "tool", "version", "softwareLicense", "purpose"},
                f"{label} tempoDerivation",
            )
            require(
                entry["tempoDerivation"]["softwareLicense"] == "GPL-3.0-or-later",
                f"{label} needs the FFmpeg software license",
            )

    require(len(analysis.get("pairs", [])) == 16, "audio analysis must cover 16 tempo pairs")
    require(analysis.get("allPitchPreserved") is True, "teaching tracks failed pitch-preservation analysis")
    require(analysis.get("allTempoVerified") is True, "teaching tracks failed tempo analysis")


def load_and_validate(pack_path: Path) -> dict[str, Any]:
    try:
        data = json.loads(pack_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValidationError(f"could not read {pack_path}: {error}") from error
    require(isinstance(data, dict), "pack root must be an object")
    validate_pack(data)
    validate_reference_audio(data, pack_path.parent)
    return data


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pack", nargs="?", type=Path, default=DEFAULT_PACK)
    args = parser.parse_args()
    try:
        data = load_and_validate(args.pack)
    except ValidationError as error:
        print(f"INVALID: {error}", file=sys.stderr)
        return 1
    print(
        f"VALID: {args.pack} ({len(data['lines'])} lines, "
        f"{len(data['lexicon'])} lexemes, {len(data['rules'])} evidence rules)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
