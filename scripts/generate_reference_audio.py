#!/usr/bin/env python3
"""Generate precise and naturalized Rǫdd reference tracks reproducibly."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import subprocess
import wave
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
PACK_PATH = ROOT / "content/prayer-packs/sigrdrifumal-west-norse-ca-1200/pack.json"
OUTPUT_ROOT = PACK_PATH.parent / "reference-audio"
TEMPO_FACTOR = 0.72

# eSpeak NG Kirshenbaum strings derived from the canonical IPA in pack 1.0.0.
# E: is the contract-accepted [ɛ:] realization of æ; eI/aU are eSpeak's close
# realizations of the target falling diphthongs.
PRECISE_INPUTS = {
    "sigrdrifumal-03-01": "h'eIl|l||d'aQR_:h'eIliR||d'axs||s'yniR",
    "sigrdrifumal-03-02": "h'eIl||n'o:t|t||'ok||n'ipt",
    "sigrdrifumal-03-03": "'o:ReIDum||'aUQum||l'i:tiD||'ok|kR||T'iniQ",
    "sigrdrifumal-03-04": "'ok||g'eBiD||s'itjOndum||s'iQR",
    "sigrdrifumal-04-01": "h'eIliR||'E:siR_:h'eIlaR||'a:synjuR",
    "sigrdrifumal-04-02": "h'eIl||sj'a:||'in||fj'Oln,y:ta||f'old",
    "sigrdrifumal-04-03": "m'a:l||'ok||m'anB,it||g'eBiD||'ok|kR||m'E:Rum||tB'eIm",
    "sigrdrifumal-04-04": "'ok||l'E:knis,h'endR||m'eDan||l'iBum",
}


def run(command: list[str], *, input_text: str | None = None) -> str:
    try:
        completed = subprocess.run(
            command,
            input=input_text,
            text=True,
            check=True,
            capture_output=True,
        )
    except subprocess.CalledProcessError as error:
        details = (error.stderr or error.stdout or "no command output").strip()
        raise RuntimeError(f"command failed ({' '.join(command)}): {details}") from error
    return completed.stdout.strip()


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def wave_metadata(path: Path) -> dict[str, Any]:
    with wave.open(str(path), "rb") as audio:
        frames = audio.getnframes()
        rate = audio.getframerate()
        return {
            "sampleRate": rate,
            "channels": audio.getnchannels(),
            "sampleWidthBits": audio.getsampwidth() * 8,
            "durationSeconds": round(frames / rate, 6),
        }


def natural_input(text: str) -> str:
    # Piper's Icelandic phonemizer expects modern Icelandic orthography. This
    # grapheme-only adaptation is recorded and never treated as contract data.
    return text.replace("ǫ", "ö").replace("Ǫ", "Ö")


def normalize_audio(source: Path, target: Path) -> None:
    run([
        "ffmpeg", "-y", "-v", "error", "-i", str(source),
        "-ar", "22050", "-ac", "1", "-c:a", "pcm_s16le", str(target),
    ])


def create_teaching_tempo(source: Path, target: Path) -> None:
    run([
        "ffmpeg", "-y", "-v", "error", "-i", str(source),
        "-filter:a", f"atempo={TEMPO_FACTOR}",
        "-ar", "22050", "-ac", "1", "-c:a", "pcm_s16le", str(target),
    ])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("model_dir", type=Path)
    parser.add_argument("--piper", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, default=OUTPUT_ROOT)
    args = parser.parse_args()

    for command in ("espeak-ng", "ffmpeg"):
        if not shutil.which(command):
            raise SystemExit(f"Required command not found: {command}")
    if not args.piper.is_file():
        raise SystemExit(f"Piper executable not found: {args.piper}")

    model = args.model_dir / "is_IS-bui-medium.onnx"
    config = args.model_dir / "is_IS-bui-medium.onnx.json"
    if not model.is_file() or not config.is_file():
        raise SystemExit("Piper model files are missing; run fetch_reference_models.py first")

    pack = json.loads(PACK_PATH.read_text(encoding="utf-8"))
    lines = {line["id"]: line for line in pack["lines"]}
    if set(lines) != set(PRECISE_INPUTS):
        raise SystemExit("Precise inputs do not cover the prayer-pack lines exactly")

    output_root = args.output_root
    temp_root = output_root / ".working"
    if temp_root.exists():
        shutil.rmtree(temp_root)
    temp_root.mkdir(parents=True)
    for style in ("precise", "naturalized"):
        (output_root / style).mkdir(parents=True, exist_ok=True)

    espeak_version = run(["espeak-ng", "--version"]).splitlines()[0]
    ffmpeg_version = run(["ffmpeg", "-version"]).splitlines()[0]
    piper_python = args.piper.parent / "python"
    piper_version = run([
        str(piper_python), "-c",
        "import importlib.metadata; print(importlib.metadata.version('piper-tts'))",
    ])
    entries: list[dict[str, Any]] = []

    for line_id, line in sorted(lines.items(), key=lambda item: item[1]["order"]):
        number = line["order"]
        precise_code = PRECISE_INPUTS[line_id]
        precise_direct = f"[[{precise_code}]]"
        natural_text = natural_input(line["normalizedText"])

        raw_precise = temp_root / f"line-{number:02d}-precise.wav"
        raw_natural = temp_root / f"line-{number:02d}-naturalized.wav"
        precise_natural = output_root / "precise" / f"line-{number:02d}-natural.wav"
        precise_teaching = output_root / "precise" / f"line-{number:02d}-teaching.wav"
        natural_natural = output_root / "naturalized" / f"line-{number:02d}-natural.wav"
        natural_teaching = output_root / "naturalized" / f"line-{number:02d}-teaching.wav"

        run([
            "espeak-ng", "-v", "is", "-s", "150", "-p", "45", "-g", "4",
            "-w", str(raw_precise), precise_direct,
        ])
        run([
            str(args.piper),
            "-m", str(model), "-c", str(config), "-f", str(raw_natural),
        ], input_text=natural_text + "\n")

        normalize_audio(raw_precise, precise_natural)
        normalize_audio(raw_natural, natural_natural)
        create_teaching_tempo(precise_natural, precise_teaching)
        create_teaching_tempo(natural_natural, natural_teaching)

        precise_ipa = run(["espeak-ng", "-q", "-v", "is", "--ipa", precise_direct])
        natural_ipa = run(["espeak-ng", "-q", "-v", "is", "--ipa", natural_text])

        variants = [
            ("precise", "natural", precise_natural, precise_direct, precise_ipa),
            ("precise", "teaching", precise_teaching, precise_direct, precise_ipa),
            ("naturalized", "natural", natural_natural, natural_text, natural_ipa),
            ("naturalized", "teaching", natural_teaching, natural_text, natural_ipa),
        ]
        for style, tempo, path, synthesis_input, synthesized_ipa in variants:
            metadata = wave_metadata(path)
            relative = path.relative_to(PACK_PATH.parent).as_posix()
            entry = {
                "id": f"{line_id}-{style}-{tempo}",
                "lineId": line_id,
                "style": style,
                "tempo": tempo,
                "file": relative,
                "sha256": sha256(path),
                "contentVersion": pack["packVersion"],
                "contractId": pack["contractId"],
                "inputTarget": line["normalizedText"],
                "synthesisInput": synthesis_input,
                "synthesizedIpa": synthesized_ipa,
                **metadata,
            }
            if style == "precise":
                entry["method"] = {
                    "engine": "eSpeak NG",
                    "version": espeak_version,
                    "mode": "direct Kirshenbaum phoneme input using the Icelandic voice table",
                    "softwareLicense": "GPL-3.0-or-later",
                }
            else:
                entry["method"] = {
                    "engine": "Piper",
                    "version": piper_version,
                    "mode": "Icelandic neural text-to-speech from normalized display text with ǫ mapped to ö",
                    "softwareLicense": "GPL-3.0-or-later",
                    "model": "is_IS-bui-medium v1.0.0",
                    "modelSha256": sha256(model),
                    "modelDatasetLicense": "CC-BY-4.0",
                }
            entry["assetLicense"] = "CC-BY-4.0"
            if tempo == "teaching":
                entry["tempoDerivation"] = {
                    "sourceId": f"{line_id}-{style}-natural",
                    "method": f"FFmpeg atempo={TEMPO_FACTOR}",
                    "tool": "FFmpeg",
                    "version": ffmpeg_version,
                    "softwareLicense": "GPL-3.0-or-later",
                    "purpose": "slower playback without resampling pitch shift",
                }
            entries.append(entry)

    manifest = {
        "manifestVersion": "1.0.0",
        "contentVersion": pack["packVersion"],
        "contractId": pack["contractId"],
        "generatedBy": "scripts/generate_reference_audio.py",
        "tempoFactor": TEMPO_FACTOR,
        "entries": entries,
    }
    (output_root / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    shutil.rmtree(temp_root)
    print(f"Generated {len(entries)} reference files in {output_root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
