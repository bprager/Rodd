# Reference-playback verification

Status: accepted for RODD-007

Verified: 7 October 2026

## Outcome

Every practice line now offers the precise teaching reference and the
naturalized approximate reference at natural or slower teaching tempo. Playback
uses only files bundled with the application, so it works without a network
connection. The screen explains what each source is for and where it should not
be treated as authoritative.

Only one reference can play at a time. Starting another source or changing
tempo stops the current recording first. Playback state and progress remain
visible, and VoiceOver announces starts, stops, completion, failures, tempo
changes, and recovery after the default audio output changes.

Teaching tempo selects a separately generated recording rather than slowing the
audio during playback. This preserves the pitch behavior already verified when
the reference pack was produced.

## Acceptance evidence

| Requirement | Evidence |
| --- | --- |
| Precise and natural references | Both labeled sources are available on each of the eight line-practice screens, with their purpose and limitation text taken from prayer pack 1.1.0. |
| Natural and teaching tempos | The tempo control chooses one of two prerecorded files for the active source. The manifest loader requires all 32 line, source, and tempo combinations before the pack can open. |
| One source at a time | A single playback controller owns one audio player. Automated checks verify source switching and play/stop toggling. |
| Visible and announced state | The line header and playback panel show the current state and progress. Automated checks verify completion and failure messages and announcements; the packaged app accessibility audit found the playback controls. |
| Pitch-safe tempo change | Teaching tempo uses the generated teaching file. Analysis of all 16 natural/teaching pairs passed, with a maximum median-pitch difference of 58.692 cents and duration ratios from 1.3690 to 1.3853. |
| Offline playback | A muted live audit used the packaged application and its bundled WAV files with no network service. |
| Audio-output changes | The app watches the system default output. If it changes during playback, the current file is reopened at the same position and resumed; success and failure paths are both checked. |

## Verification

The application build runs 17 completion checks and then a muted live playback
audit through the packaged app. The audit plays one source, switches sources,
simulates a default-output change, changes tempo, and stops:

```sh
scripts/build_macos_app.sh
```

The packaged application also passed live accessibility-tree audits on Today
(245 labeled or valued elements) and Line Practice (260). The reference-audio
validator and its eight automated tests continue to pass, including the pitch
and tempo analysis used above.

The Line Practice screen was inspected in the built application after the
controls were added. Labels, source explanations, tempo choices, buttons, and
status remained readable without clipping.

## Current boundary

This milestone does not request microphone permission, record the learner, or
judge pronunciation. Those responsibilities begin with RODD-008: recording and
the audio-quality gate.
