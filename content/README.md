# Rǫdd content

Rǫdd keeps teaching content separate from application code. Each prayer pack is
a versioned, offline JSON document validated before release.

The first pack is
[`sigrdrifumal-west-norse-ca-1200`](prayer-packs/sigrdrifumal-west-norse-ca-1200/pack.json).
It contains the eight pedagogical lines from Sigrdrífumál stanzas 3–4, their
normalized tokens, pronunciation targets, accepted variants, evidence rules,
source metadata, and 32 dual-style reference recordings. Pack 1.1.0 provides a
precise contract-led reference and an explicitly approximate naturalized
reference, each at natural and pitch-preserving teaching tempos.

Run the built-in validation without installing dependencies:

```sh
python scripts/validate_prayer_pack.py
python -m unittest discover -s tests -v
```

The JSON Schema documents the portable format. The Python validator additionally
checks relationships that JSON Schema alone does not express, such as unique
identifiers, valid references, two-source support for high-confidence rules, and
the rule that low-confidence details cannot affect mastery.

## Rebuilding reference audio

The committed audio is usable offline; rebuilding it is optional. Regeneration
requires eSpeak NG 1.52.0, FFmpeg 9.0.2, Python with `piper-tts` 1.8.0, and the
verified Búi model. From the repository root:

```sh
python scripts/fetch_reference_models.py /tmp/rodd-reference-models
python scripts/generate_reference_audio.py /tmp/rodd-reference-models \
  --piper /path/to/piper
python scripts/analyze_reference_audio.py
python scripts/validate_prayer_pack.py
```

The manifest records exact inputs, methods, licenses, versions, and checksums.
See the [comparison report](../docs/reference-audio-comparison.md) for the
reviewed disagreements and release decision.
