# Old Norse Pronunciation Contract

**Identifier:** `ON-WN-C1200-v1.0`

**Status:** Working source document. It becomes the application's authoritative
contract only after its rule-level evidence ledger and complete eight-line text
package pass the acceptance checks in `BACKLOG.md`.

## 1. Scope

This contract defines the canonical pronunciation the application teaches, generates, recognizes, evaluates, and corrects.

It is an operational reconstruction, not a claim that all medieval Scandinavians spoke identically.

**Target:**
- Old West Norse, specifically the Old Icelandic literary tradition
- approximately AD 1150 to 1250
- normalized Old Icelandic spelling
- careful spoken recitation

The University of Texas materials describe reconstructed “classical” Old Norse approximately as AD 1150 to 1350 and distinguish it from Modern Icelandic.

This is appropriate for Eddic texts. The Codex Regius manuscript dates to around 1270 to 1275, while many poems may preserve older material and cannot be assigned one secure original pronunciation date.

## 2. Confidence classes

- **A, Strong (`high`):** teach and score strictly
- **B, Probable (`medium`):** teach one target, accept close alternatives
- **C, Uncertain (`low`):** teach a default, but do not strongly penalize plausible variants

The parenthesized values are the canonical values stored in the prayer pack.
The letter grades remain as reader-friendly shorthand in this document.

Class C features must never be presented as historically certain.

## 3. Vowels

Vowel length is phonemic and must be preserved. Long vowels should generally be about 1.5 to 2 times the duration of corresponding short vowels.

| Spelling | Canonical IPA | Confidence |
|---|---|---|
| a | /a/ | A |
| á | /aː/ | A |
| e | /e/ | A |
| é | /eː/ | A |
| i | /i/ | A |
| í | /iː/ | A |
| o | /o/ | A |
| ó | /oː/ | A |
| u | /u/ | A |
| ú | /uː/ | A |
| y | /y/ | A |
| ý | /yː/ | A |
| ø | /ø/ | A |
| œ | /øː/ | A |
| ǫ | /ɔ/ | B |
| æ | /æː/ | B |

Accept [ɛː] for `æ`, and moderate openness variation for `ǫ`.

The front rounded vowels `y, ý, ø, œ` remain distinct from `i, í, e, é`.

## 4. Diphthongs

| Spelling | Canonical | Accepted range | Confidence |
|---|---|---|---|
| ei | /ei̯/ | [ei̯ ~ ɛi̯] | B |
| au | /au̯/ | [au̯ ~ ɔu̯] | B |
| ey | /øy̯/ | modest onset variation | B |

Maintain them as genuine diphthongs.

## 5. Core consonants

| Spelling | IPA | Confidence |
|---|---|---|
| p b t d k | /p b t d k/ | A |
| m n l | /m n l/ | A |
| r | /r/ | A |
| s h | /s h/ | A |
| þ | /θ/ | A |
| ð | /ð/ | A |
| j | /j/ | A |

`r` should be an alveolar trill [r]. A tap [ɾ] is acceptable, but English [ɹ] is not.

`þ` is [θ], `ð` is [ð].

## 6. Context-sensitive consonants

### `f`
- initial: [f]
- medial or final: [v]
- [β] accepted for voiced realization

**Confidence:** B

### `g`
- initial: [g]
- after `n`: [g]
- before `s` or `t`: [x]
- otherwise, especially intervocalically: [ɣ]

**Confidence:** B

### `v`
Canonical target: [β]

Accept:
- [β], preferred
- [v], acceptable

**Confidence:** B. Historical `v` developed from a semivowel and changed over time.

### `n`
Before `k` or `g`, use [ŋ].

**Confidence:** A

## 7. Special clusters

### `hl`, `hn`, `hr`
Teach:

- `hl` = [hl̥]
- `hn` = [hn̥]
- `hr` = [hr̥]

Accept realizations dominated by [l̥], [n̥], [r̥].

**Confidence:** B

### `hv`
Canonical: [hʷ]

Also accept:
- [xʷ]
- [hβ]
- [ʍ]

**Confidence:** C

## 8. Consonant length

Doubled consonants are genuinely long:

- `nn` = [nː]
- `ll` = [lː]
- `tt` = [tː]
- `kk` = [kː]

This distinction should be measured explicitly.

**Confidence:** A

## 9. Stress

Primary stress falls on the first syllable of the word stem.

For compounds:
- primary stress on the first element
- secondary stress on the beginning of the second element

**Confidence:** A

Incorrect primary stress should be strongly penalized.

## 10. Unstressed vowels

Do not systematically reduce them to English schwa /ə/.

Canonical targets:
- `a` → [a]
- `i` → [i]
- `u` → [u]

Moderate natural centralization is acceptable. Classical Old Norse unstressed syllables principally contain `a`, `i`, and `u`.

**Confidence:** B

## 11. Orthographic special cases

- `x` = /ks/
- `z` = /ts/
- `c` = /k/
- `q`, `qu` normalize to `k`, `kv`
- `w` normalizes to `v`

Classical descriptions note that `z` represents historical consonant plus `s`, while `x` represents `k+s`.

## 12. Modern Icelandic features explicitly excluded

Do not import these into the canonical target:

- `á` must be [aː], not Modern Icelandic [au]
- `y` must not merge with `i`
- do not add epenthetic `u`, so `maðr` stays a final consonant cluster rather than becoming `maður`
- `ll` is [lː], not the characteristic Modern Icelandic lateral stop-like sound
- `kk`, `pp`, `tt` do not require Modern Icelandic preaspiration

The classical and modern systems differ on these points.

## 13. Aspiration

Canonical:

[p t k]

Accept:

[pʰ tʰ kʰ]

provided identity and timing remain correct.

**Confidence:** C

Do not spend much training effort correcting aspiration.

## 14. Intonation

No single sentence melody should be labeled “authentic Old Norse intonation.”

Teach:
1. lexical stress
2. syllable timing
3. vowel quantity
4. consonant quantity
5. phrase grouping

Pitch contour and expressive intonation are not historically scoreable.

**Confidence:** C

## 15. Poetry and chanting

Musical duration must not alter linguistic quantity.

Maintain separate fields:

`linguistic_duration`

`performance_duration`

A singer may hold a short vowel for musical reasons, but it remains phonologically short.

## 16. Evaluation priorities

### Tier 1, critical
Correct immediately:
- wrong phoneme
- vowel length
- monophthong versus diphthong
- consonant gemination
- primary stress
- omitted consonants

### Tier 2, important
Correct after Tier 1:
- `þ` versus `ð`
- front rounding in `y, ý, ø, œ`
- `r`
- major `g` and `f` allophones
- excessive schwa reduction

### Tier 3, refinement
Coach lightly:
- [β] versus [v]
- exact `ǫ` quality
- diphthong onset details
- aspiration
- `hv`
- intonation

Class C choices must not dominate the score.

## 17. Recognition model

The system must distinguish:

**linguistic error**, historically meaningful contrast produced incorrectly

from

**reconstruction variation**, plausible alternative historical realization

Each segment should store:

`canonical_ipa`

`accepted_variants`

`confidence`

`feature_weights`

Example:

```text
orthography: v
canonical_ipa: β
accepted_variants: [v]
confidence: B
weights:
  place: medium
  manner: medium
  voicing: high
```

## 18. Reference audio policy

Reference audio implements the contract, it does not define it.

A recording is not authoritative merely because it comes from:
- a native Icelandic speaker
- an Old Norse enthusiast
- a musician
- YouTube
- an AI speech system

If audio conflicts with the contract, replace the audio.

## 19. Text normalization

Before pronunciation generation, create a canonical normalized form.

The pipeline must:
1. preserve vowel length marks
2. preserve `þ` and `ð`
3. preserve `æ`, `œ`, `ø`, `ǫ`
4. identify compounds where possible
5. distinguish editorial spelling variants from phonological differences
6. retain the original source text

`ö` may be normalized internally to historical `ǫ` when editorial evidence supports it.

Do not modernize spelling merely to simplify TTS.

## 20. Source hierarchy

When sources disagree:

1. scholarly Old Norse phonology
2. critical or normalized scholarly edition
3. historical morphology and etymology
4. documented reconstruction variants
5. Modern Icelandic comparison
6. historically informed recordings
7. general educational recordings
8. commercial or artistic recordings

YouTube music never determines canonical pronunciation.

## 21. Transparency requirement

For every word, the application should be able to show:

- **Text:** `...`
- **Normalized form:** `...`
- **Canonical IPA:** `...`
- **Stress:** `...`
- **Uncertain features:** `...`
- **Accepted alternatives:** `...`
- **Reason for correction:** `...`

The user should be able to ask why a correction was made and receive a linguistic explanation, not merely a comparison to a reference recording.

## 22. Governing principle

The goal is not to reproduce one imagined Viking voice.

The goal is to teach a consistent, evidence-based pronunciation of Classical Old West Norse while preserving known phonemic distinctions and explicitly representing uncertainty.

Once its evidence ledger and text package pass validation, this contract is the
authoritative pronunciation standard for the application.

## Reference sources

- University of Texas Linguistics Research Center, Old Norse Online: https://lrc.la.utexas.edu/eieol/norol/10
- Cambridge University Press, *A Handbook to Eddic Poetry*, section on dating Eddic poetry: https://www.cambridge.org/core/books/abs/handbook-to-eddic-poetry/dating-of-eddic-poetry/A0F5C950CBEC52D0D522A1CBAC71D388
