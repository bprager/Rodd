# macOS application-shell verification

Status: accepted for RODD-006

Verified: 2 October 2026

## Outcome

Rǫdd now has a native SwiftUI macOS shell that opens to Today and loads prayer
pack 1.1.0 from the application itself. It does not need a network connection.
The shell includes the five planned destinations, all eight line-practice
entries, a native Settings window, and clear placeholders where later playback,
recording, recitation, and progress work will connect.

Playback and recording are deliberately absent. They belong to RODD-007 and
RODD-008 and are not represented as working controls prematurely.

## Acceptance evidence

| Requirement | Evidence |
| --- | --- |
| Opens directly to Today | The application model defaults to Today, a completion check verifies the default, and the packaged app was launched and inspected on its Today screen. |
| Keyboard navigation | Native sidebar and button controls participate in normal tab and arrow-key navigation. Command-1 through Command-5 select the five destinations, Command-comma opens Settings, Return invokes the main action, and Escape returns from line practice. Ten automated checks verify the default and route behavior, including Today opening line 1. |
| VoiceOver navigation | Controls use native macOS roles and explicit labels or hints where their visible wording is insufficient. Live self-audits of the packaged app found all required destinations and actions in the accessibility tree: 245 labeled or valued elements on Today and 255 on Line Practice. |
| Missing or incompatible content | The loader distinguishes missing, unreadable, and unsupported content and supplies a specific explanation and recovery suggestion. Automated checks inject all three conditions and verify the recovery state. |
| Supported text sizes | Settings offers Standard, Large, and Extra Large. Flexible panels, wrapping text, and scrolling avoid fixed-height clipping. Today and Line Practice were inspected at Standard and Extra Large; the full Line Practice layout remained readable and operable at Extra Large. |
| Offline local content | The complete prayer-pack directory is copied into the application resource bundle. The loader check reads pack 1.1.0 and all eight ordered lines from that bundle. |

## Verification commands

The build command creates `.build/rodd-macos/Rodd.app`, validates its signature,
and runs the completion suite:

```sh
scripts/build_macos_app.sh
codesign --verify --deep --strict .build/rodd-macos/Rodd.app
```

The completion suite contains ten checks covering bundled loading, line order,
missing content, damaged content, incompatible versions, recovery copy, initial
navigation, the Today-to-line transition, keyboard routes, supported text sizes,
and reference-style disclosure.

Debug builds also support repeatable accessibility-tree audits:

```sh
.build/rodd-macos/Rodd.app/Contents/MacOS/Rodd --accessibility-audit
.build/rodd-macos/Rodd.app/Contents/MacOS/Rodd \
  --line-practice --accessibility-audit
```

Both audits passed on the packaged application.

## Current boundary

This milestone proves the application foundation, content loading, navigation,
recovery states, text scaling, and accessibility semantics. It does not prove
audio playback, microphone capture, assessment, or stored progress. The next
work should be RODD-007: connect the already-versioned reference recordings to
exclusive, offline playback with announced state.
