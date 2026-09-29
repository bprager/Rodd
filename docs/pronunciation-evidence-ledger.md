# Pronunciation Contract v1 evidence ledger

Status: validated against prayer pack 1.0.0

Date: 29 September 2026

This ledger explains how Rǫdd turns the Sigrdrífumál source text and two
independent pronunciation guides into a cautious teaching target. The complete,
machine-readable evidence records live in
`content/prayer-packs/sigrdrifumal-west-norse-ca-1200/pack.json`.

## Sources and authority

| ID | Source | Use |
|---|---|---|
| `eae-codex-regius` | Editiones Arnamagnæanæ Electronicæ, GKS 2365 4to | Manuscript transcription, normalized reading, and witness identity |
| `pettit-2023` | Edward Pettit, *The Poetic Edda: A Dual-Language Edition* | Recent normalized critical text and verse division |
| `ut-austin-old-norse` | Krause and Slocum, University of Texas, *Old Norse Online* | Classical sound inventory, contextual consonants, quantity, and stress |
| `barnes-2008` | Michael Barnes, *A New Introduction to Old Norse*, 3rd ed. | Independent sound-system check, uncertainty, and classical-versus-modern distinction |

The first two sources establish what text is taught. The latter two establish
the pronunciation rules. A reference recording, performer, or synthesizer is
never evidence for changing the contract.

## Fixed source text

The target is GKS 2365 4to, Sigrdrífumál stanzas 3–4, divided into eight
practice lines. The division preserves the four printed verse lines in each
stanza without changing word order.

| Line | Normalized text | Canonical teaching IPA |
|---:|---|---|
| 1 | Heill dagr! Heilir dags synir! | /hei̯lː daɣr · ˈhei̯.lir daxs ˈsy.nir/ |
| 2 | Heil nótt ok nipt! | /hei̯l noːtː ok nipt/ |
| 3 | Óreiðum augum lítið okkr þinig, | /ˈoː.rei̯.ðum ˈau̯.ɣum ˈliː.tið okːr ˈθi.niɣ/ |
| 4 | ok gefið sitjǫndum sigr! | /ok ˈge.við ˈsit.jɔn.dum siɣr/ |
| 5 | Heilir æsir! Heilar ásynjur! | /ˈhei̯.lir ˈæː.sir · ˈhei̯.lar ˈaː.syn.jur/ |
| 6 | Heil sjá in fjǫlnýta fold! | /hei̯l sjaː in ˈfjɔlˌnyː.ta fold/ |
| 7 | Mál ok manvit gefið okkr mærum tveim, | /maːl ok ˈmanˌβit ˈge.við okːr ˈmæː.rum tβei̯m/ |
| 8 | ok læknishendr meðan lifum! | /ok ˈlæːk.nisˌhen.dr ˈme.ðan ˈli.vum/ |

The IPA above is a compact review view. The pack remains definitive because it
also records each syllable, quantity target, accepted variant, source, and
confidence level.

## Editorial decisions

| Decision | Selected form | Recorded alternative | Reason |
|---|---|---|---|
| Pronoun | `okkr` | `okr` | Follow Pettit's selected normalization and preserve the resulting long k target. |
| Article | `in` | `hin` | Follow the EAE and Pettit reading without silently mixing another edition. |
| Compound | `manvit` | `mannvit` | Follow Pettit's single-n form and avoid inventing a geminate target. |
| Historical vowel | `ǫ` | modernized `ö` | Preserve normalized Old Norse spelling in `sitjǫndum` and `fjǫlnýta`. |
| Divine feminine | `Ásynjur` | historically oriented `Ǫ́synjur` | Follow the selected critical edition's classical normalized form. |

Capitalization and punctuation are retained in the displayed edition text but
do not create separate lexicon entries. Stable line and token identifiers remain
unchanged if display punctuation later changes.

## Rule comparison

| Feature | UT Austin | Barnes | Contract decision | Confidence |
|---|---|---|---|---|
| Classical profile | Separate from Modern Icelandic | Separate systems and warns against mixing | One classical profile, approximately 1200 | High |
| Vowel identity | Classical inventory with length pairs | Sixteen oral vowels used for the ca. 1200 target | Preserve identity and quantity | High |
| `ei`, `au` | Genuine diphthongs | Long falling diphthongs | Do not accept monophthongization | High |
| Geminates | Held about twice as long | Long consonants marked by doubling | Score `ll`, `tt`, and `kk` quantity | High |
| `f` | [f] initially, [v] elsewhere | Same positional distinction | Teach the contrast; allow modest voiced-quality variation | High |
| `g` | [g] initially/after n, [x] before s/t, [ɣ] elsewhere | Same, with [k] also allowed before s/t | Teach [x], accept [k] before s/t | High distribution; medium variant |
| `v` | Spanish-b-like [β] | English-w-like [w] | Teach [β]; accept [w] and [v] | Medium |
| `p` before `s/t` | [f] | [p], with [f] allowed | Teach [p]; accept [f] | Medium |
| `r` | Trilled | Rolled | Teach [r]; accept [ɾ] as a practical variant | High identity |
| Stress | First stem syllable; secondary compound stress | First syllable in principle | First-element primary and second-element secondary stress | High primary; medium secondary |
| Unstressed vowels | Short `a`, `i`, `u` | Three-way `a`, `i`, `u` contrast | Do not systematically reduce to schwa | High |
| Intonation | Not established as a scoring target | Nothing known for sure; likely regional variation | Guidance only; never affects mastery | Low and non-scorable |

## Confidence and coaching policy

- **High:** two independent scholarly teaching sources agree on the relevant
  contrast. The app may correct it when the recording evidence is also strong.
- **Medium:** a defensible default exists, but source disagreement or exact
  phonetic uncertainty remains. Every recorded alternative must be accepted.
- **Low:** insufficient evidence for a historical judgment. The detail may be
  described, but it cannot affect a score or mastery.

Historical confidence never substitutes for acoustic confidence. A high-confidence
rule still produces no correction when the recording is unclear.

## Validation result

Prayer pack 1.0.0 contains:

- eight ordered lines covering stanzas 3–4;
- 31 unique normalized word forms;
- 19 evidence rules;
- explicit syllables, stress, quantity targets, variants, sources, and teaching
  notes for every word;
- stable identifiers for lines, words, rules, and sources.

The offline validator rejects unresolved identifiers, duplicate identifiers,
missing line coverage, invalid confidence labels, high-confidence rules with
fewer than two sources, and any low-confidence rule that is allowed to affect
mastery. Automated tests also exercise these rejection paths.

## Remaining limits

This is a reproducible internal evidence review, not review by a specialist in
Old Norse historical phonology. Exact phonetic shades, especially `v`, `ǫ`,
`æ`, secondary compound stress, and connected-speech effects, remain deliberately
permissive. Reference audio must be generated and compared by two independent
methods before it can ship, and it may not override this ledger.
