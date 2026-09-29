import copy
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from validate_prayer_pack import DEFAULT_PACK, ValidationError, load_and_validate, validate_pack


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


if __name__ == "__main__":
    unittest.main()
