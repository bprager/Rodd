# Rǫdd product backlog

Status: proposed

Last reviewed: 29 September 2026

## How to use this backlog

Items are ordered by dependency and risk, not by feature appeal. **P0** work is
required for an honest prototype, **P1** completes a useful alpha, and **P2**
extends the product after the alpha is trustworthy. An item is complete only
when its acceptance checks are demonstrated and its evidence is stored in the
repository.

## Milestone 0 — Pronunciation contract

The app must know and disclose what it teaches before it attempts to judge a
learner.

### RODD-001 · Freeze the source text — P0

Choose the normalized Codex Regius reading of all eight target lines while
preserving the manuscript source and documenting every editorial normalization.

**Acceptance**

- The complete target text is stored as versioned content.
- Each normalization links to its source and rationale.
- Stable line, word, and character identifiers survive display changes.

### RODD-002 · Declare the historical profile — P0

Write the exact scope and limits of “Classical West Norse or Old Icelandic,
approximately 1200,” including how it differs from a modern Icelandic reading.

**Acceptance**

- The profile has a stable identifier and reader-friendly description.
- Included and excluded historical assumptions are explicit.
- No profile rule silently falls back to modern Icelandic.

### RODD-003 · Build the evidence ledger — P0

Record the rule, sources, disagreement, selected realization, and confidence for
every sound, stress, and length target.

**Depends on:** RODD-001, RODD-002

**Acceptance**

- Every target phone traces to a rule and at least one source.
- High-confidence rules have two independent academic sources where available.
- Medium and low-confidence decisions expose alternatives and cannot silently
  block mastery.

### RODD-004 · Produce the versioned prayer pack — P0

Encode text, phone sequences, syllables, stress, length, variants, teaching
notes, evidence, and content identifiers in a validated local package.

**Depends on:** RODD-003

**Acceptance**

- An automated check rejects missing references, invalid identifiers, and
  variants without confidence metadata.
- The pack can be loaded without network access.
- A content change produces a new version while old attempt records remain
  interpretable.

### RODD-005 · Generate and review dual reference tracks — P0

Create a precise teaching reference and a more natural, explicitly approximate
reference for every practice unit.

**Depends on:** RODD-004

**Acceptance**

- Every audio file records its method, license, input target, and content version.
- A comparison report identifies disagreements between the two methods.
- Each track has natural-speed and teaching-tempo playback without pitch damage.
- The interface labels the purpose and limitations of both styles.

## Milestone 1 — Honest coach prototype

### RODD-006 · Create the macOS application shell — P0

Build the sidebar, Today view, Line practice view, Settings entry, and local
prayer-pack loader using native macOS controls.

**Depends on:** RODD-004

**Acceptance**

- The app opens directly to Today and navigates fully by keyboard and VoiceOver.
- Missing or incompatible content produces a useful recovery message.
- The primary layouts remain usable at the supported text sizes.

### RODD-007 · Implement reference playback — P0

Support precise and natural reference playback at natural and teaching speeds.

**Depends on:** RODD-005, RODD-006

**Acceptance**

- Only one source plays at a time and playback state is visible and announced.
- Speed changes do not unexpectedly alter pitch.
- Playback works offline and responds correctly to system output changes.

### RODD-008 · Implement recording and the audio-quality gate — P0

Capture a learner attempt, preserve it for A/B playback, and detect capture
conditions that make pronunciation judgment unsafe.

**Depends on:** RODD-006

**Acceptance**

- Permission, denied-permission, missing-input, clipping, low-level, high-noise,
  early-speech, and interruption paths have tested recovery instructions.
- Press-and-hold and press-once recording both work.
- The analysis copy is mono 16 kHz PCM while playback preserves the original.

### RODD-009 · Establish the recognizer baseline — P0

Convert and benchmark the initial multilingual phone recognizer on the target
Mac, then compare it with any viable challenger.

**Depends on:** RODD-004

**Acceptance**

- License, installed size, memory, cold start, and per-line latency are recorded.
- Evaluation includes canonical, variant, substituted, omitted, and inserted
  sounds rather than open-ended transcription accuracy.
- The selected baseline and rejected alternatives have documented reasons.

### RODD-010 · Build known-text alignment — P0

Align recognizer evidence with canonical targets, accepted variants, likely
substitutions, insertions, and omissions.

**Depends on:** RODD-009

**Acceptance**

- Automated fixtures cover exact, accepted-variant, substitution, insertion,
  deletion, and repeated-sound cases.
- The result identifies words and sounds without requiring brittle fixed
  boundaries.
- Low alignment confidence triggers abstention rather than a specific correction.

### RODD-011 · Add quantity analysis — P0

Measure vowels and doubled consonants relative to the phrase and learner rate.

**Depends on:** RODD-010

**Acceptance**

- Controlled shortened and lengthened recordings rank in the expected order.
- Feedback describes a relative change and does not demand unsupported absolute
  durations.
- Quantity judgments carry their own confidence.

### RODD-012 · Deliver one correction and A/B replay — P0

Prioritize the highest-value supported issue and let the learner compare the
same unit in the reference and personal recording.

**Depends on:** RODD-007, RODD-008, RODD-010, RODD-011

**Acceptance**

- At most one correction appears for an attempt.
- Meaning-bearing omissions and substitutions outrank length, allophone, and
  rhythm guidance.
- Uncertain results ask for another attempt or explain why the app cannot judge.
- Word-level reference and learner playback can be reached without losing place.

## Milestone 2 — Calibrated alpha

### RODD-013 · Build the acoustic calibration set — P0

Collect dual-synthesis references, controlled mutations, and representative
learner recordings under varied distance, level, rate, and noise.

**Depends on:** RODD-005, RODD-010, RODD-011

**Acceptance**

- Every critical target has positive, accepted-variant, and known-error examples.
- Dataset provenance and consent are documented.
- A repeatable evaluation reports results by sound, error type, and capture
  condition.

### RODD-014 · Calibrate confidence and abstention — P0

Turn model evidence into tested accept, correct, retry, and cannot-judge
decisions without presenting raw probability as historical truth.

**Depends on:** RODD-013

**Acceptance**

- Critical injected sound and length errors reach at least 85% recall.
- Accepted synthetic variants stay below 5% false rejection.
- Results appear within 700 milliseconds per line on the target M4 Mac.
- The report includes false corrections and abstentions, not only aggregate
  accuracy.

### RODD-015 · Store private, versioned history — P1

Persist attempts, mastery effects, content and model versions, settings, and
optional recordings locally.

**Depends on:** RODD-012

**Acceptance**

- Old results remain attributable after content or model updates.
- Recording retention can be disabled or limited.
- Deleting history deletes linked retained audio and is verified on disk.
- The application functions without an account or network permission.

### RODD-016 · Complete first-run onboarding — P1

Introduce the pronunciation profile, privacy model, microphone permission, and
sound check in a short flow.

**Depends on:** RODD-008, RODD-015

**Acceptance**

- Permission is requested only when its purpose is visible.
- A learner can recover from denied permission through clear system guidance.
- Sound check distinguishes capture quality from pronunciation assessment.
- The flow is complete with keyboard and VoiceOver alone.

### RODD-017 · Add cautious rhythm guidance — P1

Compare normalized pitch, energy, pause, and syllable-duration contours with the
reference while clearly limiting the historical claim.

**Depends on:** RODD-013

**Acceptance**

- Rhythm guidance never blocks mastery.
- Copy describes similarity to the selected reference style, not historical
  correctness.
- Rate and pitch-range normalization are tested on representative recordings.

### RODD-018 · Run the alpha release gate — P0

Evaluate the complete line-practice loop against the product, privacy,
accessibility, reliability, accuracy, and latency gates.

**Depends on:** RODD-014, RODD-015, RODD-016, RODD-017

**Acceptance**

- Every release gate in the app design has linked evidence.
- Known failures and unsupported environments are visible to the learner.
- No unresolved false-correction issue can cause a high-confidence teaching cue.

## Milestone 3 — Teaching product

### RODD-019 · Build adaptive seven-minute sessions — P1

Schedule a balanced sequence of listening, production, correction, and recall
from mastery and due-review data.

**Depends on:** RODD-015, RODD-018

**Acceptance**

- A default session begins with one action and needs no technical choices.
- Immediate, same-session, next-day, three-day, one-week, and three-week reviews
  can be scheduled and tested with a controllable clock.
- Session changes remain explainable from current mastery and due reviews.

### RODD-020 · Build the sound workshops — P1

Teach the initial difficult sound inventory through listening discrimination,
mouth cues, production, and return to a word or line.

**Depends on:** RODD-012, RODD-018

**Acceptance**

- Initial workshops cover vowel length, geminates, /y/, /ɣ/, /ð/, and /r/.
- Every audio cue has a textual equivalent.
- A workshop can be inserted after repeated high-confidence evidence without
  assuming inability from one attempt.

### RODD-021 · Implement mastery — P1

Track New, Practicing, Reliable, and Mastered states from repeated unprompted
performance rather than one high result.

**Depends on:** RODD-014, RODD-015, RODD-019

**Acceptance**

- Mastery requires three acceptable unprompted attempts across two sessions.
- A critical high-confidence sound or quantity issue prevents mastery.
- Low-confidence historical details and rhythm guidance cannot prevent mastery.
- State changes remain explainable to the learner.

### RODD-022 · Build uninterrupted full recitation — P1

Record the full greeting with optional text hiding and provide feedback only
after completion.

**Depends on:** RODD-018, RODD-021

**Acceptance**

- Recording never interrupts with coaching or sound effects.
- Post-session review identifies a strength, one next priority, and line-level
  detail.
- Cancelling or experiencing a capture failure does not affect mastery.

### RODD-023 · Build the progress view — P1

Show line mastery, recurring high-confidence sound issues, and upcoming reviews.

**Depends on:** RODD-019, RODD-021

**Acceptance**

- The view answers what is learned, what needs work, and what comes next.
- It exposes no competitive ranking or misleading overall accuracy percentage.
- Every state and chart remains understandable without color.

### RODD-024 · Complete accessibility and privacy review — P0

Test the complete learning journey with macOS accessibility settings and verify
local-data behavior before release.

**Depends on:** RODD-020, RODD-022, RODD-023

**Acceptance**

- A complete session works with keyboard and VoiceOver.
- Supported text scaling, contrast, reduced motion, and non-color cues pass.
- Network isolation, data export or inspection, retention, and deletion behavior
  have repeatable verification evidence.

## Later opportunities — P2

These stay outside the first release until RODD-024 passes:

- a separately named modern Icelandic reading profile;
- additional prayer packs and historical-language texts;
- user-authored practice material with explicitly weaker assessment guarantees;
- iPhone and iPad companions;
- optional device-to-device progress transfer without an account.

They require new research and are not commitments.
