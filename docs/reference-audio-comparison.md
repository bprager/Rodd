# Dual reference-audio comparison

Status: accepted for prayer pack 1.1.0

Reviewed: 29 September 2026

## Decision

Rǫdd ships two clearly different synthetic references for each of the eight
practice lines. The **Precise teaching reference** is the pronunciation target
because its phoneme input follows the versioned `west-norse-ca-1200` contract.
The **Naturalized approximate reference** is a listening aid for smoother
phrasing. It uses a Modern Icelandic voice and must never determine a learner's
score or silently override the contract.

Neither reference is evidence of medieval voice quality, accent, intonation,
or performance practice. Where the references disagree, the prayer pack and
evidence ledger govern.

## Methods reviewed

| Reference | Method | Useful for | Known limitation |
| --- | --- | --- | --- |
| Precise teaching | eSpeak NG 1.52.0 with direct phoneme input | Stable segment, stress, and quantity targets | Deliberately synthetic; connected phrasing is less natural |
| Naturalized approximate | Piper 1.8.0 with `is_IS-bui-medium` 1.0.0 | More continuous timing and phrasing | Reads the text through a Modern Icelandic sound system |

Licenses, inputs, content versions, checksums, and exact software/model details
are recorded in the audio manifest and attribution file.

## Material disagreements

The comparison used the generated audio, each method's recorded synthesis
input, and the contract's canonical word-level IPA. These are the differences a
learner is most likely to hear; the list is not a claim of exhaustive acoustic
measurement.

| Line | Words affected | What the naturalized reference changes |
| --- | --- | --- |
| 1 | `heill`, `dagr`, `synir` | Uses the Modern Icelandic `ll` sound and modern vowel qualities; the precise track retains the contract's long lateral, historical vowels, and trill. |
| 2 | `nótt`, `ok`, `nipt` | Introduces modern diphthonging, pre-aspiration/voicing patterns, and modern vowel length instead of the declared historical targets. |
| 3 | `Óreiðum`, `augum`, `þinig`, `okkr` | Modernizes `ó` and `au`, changes final and cluster behavior, and does not preserve every historical quantity target. |
| 4 | `gefið`, `sitjǫndum`, `sigr` | Palatalizes or modernizes consonants and shifts vowel quality; the precise track follows the pack's historical consonant and quantity rules. |
| 5 | `heilir`, `æsir`, `heilar`, `ásynjur` | Realizes `æ` and `á` as Modern Icelandic diphthongs and applies modern vowel/consonant timing. |
| 6 | `sjá`, `fjǫlnýta`, `fold` | Modernizes `á`, vowel quality, and length; the precise track preserves the declared `ǫ`, `ý`, and quantity targets. |
| 7 | `mál`, `mannvit`, `gefið`, `mærrum`, `tveim` | Modernizes `á` and `æ`, with further vowel, fricative, and timing differences. |
| 8 | `læknishendr`, `meðan`, `lifum` | Uses modern diphthongs, consonant clusters, and vowel qualities rather than the historical contract's segment sequence. |

## Tempo and pitch review

Every natural-speed track has a teaching-tempo partner derived with FFmpeg's
pitch-preserving tempo filter at a factor of 0.72. Automated analysis passed all
16 pairs. Measured teaching-to-natural duration ratios range from about 1.37 to
1.39, close to the expected 1.39, and every median-pitch difference is within
79 cents of its source. The release threshold is 80 cents.

The measurements are a release guard, not a claim that pitch trackers are
perfect. Checksums make every reviewed file identifiable, and regeneration is
scripted so a future tool or content change can be compared rather than silently
replacing these assets.

## Interface wording

The prayer pack stores the labels, purposes, and limitations the application
must show:

- **Precise teaching reference:** follows the declared historical contract;
  synthetic delivery cannot establish authentic medieval prosody.
- **Naturalized approximate reference:** offers smoother listening practice;
  Modern Icelandic features are expected and are not the scoring target.
- **Natural speed:** the generated baseline pace.
- **Teaching tempo:** a slower, pitch-preserving derivative for close practice.
