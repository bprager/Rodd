# Changelog

All notable changes to Rǫdd will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and releases will follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
once application builds begin. Release dates use the ISO 8601 `YYYY-MM-DD`
format.

## [Unreleased]

### Added

- A product baseline for a private, offline macOS pronunciation coach focused on
  the eight-line Sigrdrífumál greeting.
- An app design covering the learning journey, navigation, core screens, visual
  direction, accessibility, feedback language, privacy, system boundaries, and
  release gates.
- A dependency-ordered backlog from source-text research through a validated
  teaching product, with priorities and acceptance checks for each item.
- A project-document index and current-status summary in the README.
- A working Classical Old West Norse pronunciation contract covering the sound
  system, accepted variation, evaluation priorities, and reference-audio policy.
- Pronunciation Contract v1 for all eight target lines, with normalized text,
  word-level IPA, syllables, stress, quantity, variants, and teaching notes.
- A versioned offline prayer pack containing 31 word forms and 19 evidence-backed
  pronunciation rules.
- A dependency-free validator and automated relationship tests for the pack.
- Precise and naturalized synthetic references for all eight lines at natural
  and pitch-preserving teaching tempos, with reproducible generation scripts.
- A versioned reference-audio manifest recording synthesis inputs, tools,
  licenses, content versions, file formats, durations, and checksums.
- A comparison report documenting the audible disagreements between the
  historical teaching target and the Modern Icelandic naturalized reference.
- Automated tempo and pitch-preservation analysis covering all 16 audio pairs.
- A native macOS application shell with Today, Lines, Sounds, Recite, Progress,
  line-practice, and Settings views.
- An offline bundled prayer-pack loader with clear recovery guidance for
  missing, damaged, and incompatible content.
- Keyboard navigation, explicit accessibility descriptions, three supported
  reading sizes, and live accessibility-tree checks for the primary screens.
- A repeatable macOS application build that produces an ad-hoc-signed local app
  and runs ten completion checks.

### Changed

- The initial release teaches one declared historical reconstruction and keeps a
  modern Icelandic profile out of scope.
- The first milestone is the source-backed pronunciation contract, before app
  development or automated judgment begins.
- Pronunciation research is now checked against the Codex Regius electronic
  edition, a recent critical edition, and two independent academic teaching
  sources before it can become executable content.
- The supplied pronunciation document is now the human-readable contract for the
  validated, machine-readable pack rather than an unsupported standalone draft.
- Documented source disagreements for written `v` and `p` before `t` are accepted
  alternatives instead of being scored as learner errors.
- Numeric pronunciation scores, cloud accounts, social features, and additional
  texts are outside the first release.
- The prayer pack is now version 1.1.0 and includes interface-ready labels that
  state the purpose and limitations of both reference styles and tempos.
- Project status now advances to reference playback; playback and recording
  controls remain intentionally deferred to their dedicated milestones.

## [0.1.0] - 2026-09-27

### Added

- Initial product and technical research for an Old Norse pronunciation coach,
  including the pronunciation contract, teaching method, assessment approach,
  macOS architecture, validation strategy, risks, and phased delivery plan.
