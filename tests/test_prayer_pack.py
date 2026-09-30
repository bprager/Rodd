import copy
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from validate_prayer_pack import (
    DEFAULT_PACK,
    ValidationError,
    load_and_validate,
    validate_pack,
    validate_reference_audio,
)


class PrayerPackTests(unittest.TestCase):
    def setUp(self):
        self.pack = load_and_validate(DEFAULT_PACK)

    def test_pack_has_eight_ordered_lines(self):
        self.assertEqual([line["order"] for line in self.pack["lines"]], list(range(1, 9)))

    def test_every_line_token_resolves(self):
        lexeme_ids = {entry["id"] for entry in self.pack["lexicon"]}
        for line in self.pack["lines"]:
            self.assertTrue(set(line["tokenIds"]).issubset(lexeme_ids))

    def test_high_confidence_rules_have_two_sources(self):
        for rule in self.pack["rules"]:
            if rule["confidence"] == "high":
                self.assertGreaterEqual(len({item["sourceId"] for item in rule["evidence"]}), 2)

    def test_low_confidence_rules_cannot_affect_mastery(self):
        for rule in self.pack["rules"]:
            if rule["confidence"] == "low":
                self.assertFalse(rule["scorable"])

    def test_unknown_token_is_rejected(self):
        changed = copy.deepcopy(self.pack)
        changed["lines"][0]["tokenIds"].append("not-in-the-lexicon")
        with self.assertRaises(ValidationError):
            validate_pack(changed)

    def test_low_confidence_scorable_rule_is_rejected(self):
        changed = copy.deepcopy(self.pack)
        changed["rules"].append(
            {
                "id": "invalid-low-rule",
                "category": "prosody",
                "statement": "Deliberately invalid fixture.",
                "confidence": "low",
                "scorable": True,
                "evidence": [
                    {
                        "sourceId": changed["sources"][0]["id"],
                        "locator": "test",
                        "position": "test fixture"
                    }
                ]
            }
        )
        with self.assertRaises(ValidationError):
            validate_pack(changed)

    def test_reference_audio_covers_every_line_style_and_tempo(self):
        manifest_path = DEFAULT_PACK.parent / self.pack["referenceAudio"]["manifest"]
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        combinations = {
            (entry["lineId"], entry["style"], entry["tempo"])
            for entry in manifest["entries"]
        }
        self.assertEqual(len(manifest["entries"]), 32)
        self.assertEqual(len(combinations), 32)
        self.assertTrue(all(entry["method"]["softwareLicense"] for entry in manifest["entries"]))

    def test_reference_audio_checksum_tampering_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            copied_root = Path(directory) / "pack"
            shutil.copytree(DEFAULT_PACK.parent, copied_root)
            damaged = copied_root / "reference-audio/precise/line-01-natural.wav"
            damaged.write_bytes(damaged.read_bytes() + b"tampered")
            with self.assertRaises(ValidationError):
                validate_reference_audio(self.pack, copied_root)


if __name__ == "__main__":
    unittest.main()
