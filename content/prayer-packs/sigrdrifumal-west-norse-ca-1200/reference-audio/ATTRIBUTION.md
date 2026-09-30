# Reference-audio attribution and licensing

The 32 generated WAV files in this directory are copyright 2026 Rǫdd
contributors and are licensed under the
[Creative Commons Attribution 4.0 International license](https://creativecommons.org/licenses/by/4.0/).

## Precise teaching reference

The precise tracks were synthesized with
[eSpeak NG](https://github.com/espeak-ng/espeak-ng), version 1.52.0, using
direct phoneme input derived from Rǫdd's `west-norse-ca-1200` pronunciation
contract. eSpeak NG is licensed under GPL-3.0-or-later. The exact input,
software version, target text, content version, and output checksum are recorded
in `manifest.json`.

These tracks are an intentionally careful teaching aid. They implement the
declared contract but do not claim to reproduce an attested medieval voice,
accent, rhythm, or performance style.

## Naturalized approximate reference

The naturalized tracks were synthesized with
[Piper](https://github.com/OHF-Voice/piper1-gpl), version 1.8.0, and the
`is_IS-bui-medium` voice model, version 1.0.0. Piper 1.8.0 is licensed under
GPL-3.0-or-later. The model was trained from the Talrómur 1 corpus, licensed
under CC BY 4.0 and created by Atli Þór Sigurgeirsson, Þorsteinn Daði
Gunnarsson, Gunnar Thor Örnólfsson, Ragnheiður Þórhallsdóttir, Eydís Huld
Magnúsdóttir, and Jón Guðnason. See the
[Talrómur 1 record](https://hdl.handle.net/20.500.12537/104) and the
[Piper voice model card](https://huggingface.co/rhasspy/piper-voices/blob/main/is/is_IS/bui/medium/MODEL_CARD).

The corpus creators and recorded speakers did not record these Old Norse lines,
and their attribution does not imply endorsement. These tracks demonstrate a
more flowing synthetic delivery, but they carry Modern Icelandic pronunciation
into historical text and are not the pronunciation target.

## Teaching-tempo derivation

Each teaching-tempo file was derived from its natural-speed counterpart with
FFmpeg's `atempo=0.72` filter. The installed FFmpeg 9.0.2 build is licensed
under GPL-3.0-or-later. This changes duration while preserving pitch within the
limits measured in `analysis.json`.
