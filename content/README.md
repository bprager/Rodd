# Rǫdd content

Rǫdd keeps teaching content separate from application code. Each prayer pack is
a versioned, offline JSON document validated before release.

The first pack is
[`sigrdrifumal-west-norse-ca-1200`](prayer-packs/sigrdrifumal-west-norse-ca-1200/pack.json).
It contains the eight pedagogical lines from Sigrdrífumál stanzas 3–4, their
normalized tokens, pronunciation targets, accepted variants, evidence rules,
and source metadata.

Run the built-in validation without installing dependencies:

```sh
python scripts/validate_prayer_pack.py
python -m unittest discover -s tests -v
```

The JSON Schema documents the portable format. The Python validator additionally
checks relationships that JSON Schema alone does not express, such as unique
identifiers, valid references, two-source support for high-confidence rules, and
the rule that low-confidence details cannot affect mastery.
