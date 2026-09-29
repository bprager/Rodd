#!/usr/bin/env python3
"""Validate the Rǫdd prayer pack using only the Python standard library."""

from __future__ import annotations

import argparse
import json
import re
import sys
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


def load_and_validate(pack_path: Path) -> dict[str, Any]:
    try:
        data = json.loads(pack_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValidationError(f"could not read {pack_path}: {error}") from error
    require(isinstance(data, dict), "pack root must be an object")
    validate_pack(data)
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
