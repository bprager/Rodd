# Rǫdd

Rǫdd is a private, offline macOS coach for learning a documented reconstruction
of Old Norse pronunciation. The first release focuses on the eight-line
Sigrdrífumál greeting and gives one useful correction at a time.

## Project documents

- [Product and technical research](docs/Rodd_Old_Norse_Pronunciation_Coach_Design.md)
- [App design](docs/App_Design.md)
- [Pronunciation contract](docs/old-norse-pronunciation-contract.md)
- [Pronunciation evidence ledger](docs/pronunciation-evidence-ledger.md)
- [Reference-audio comparison](docs/reference-audio-comparison.md)
- [Reference-playback verification](docs/reference-playback-verification.md)
- [macOS app-shell verification](docs/macos-app-shell-verification.md)
- [Versioned teaching content](content/README.md)
- [Prioritized backlog](BACKLOG.md)
- [Changelog](Changelog.md)

## Current status

Pronunciation Contract v1, prayer pack 1.1.0, the native macOS application
shell, and reference playback are complete. The app opens to Today, navigates
through the planned sections, loads all eight lines offline, and plays both
reference styles at natural or teaching tempo. The next milestone is recording
and the audio-quality gate.

## Build and verify the macOS app

Rǫdd requires macOS 14 or later and Apple’s command-line developer tools. The
build script creates an ad-hoc-signed application and runs the completion
checks, including muted playback through the packaged app:

```sh
scripts/build_macos_app.sh
open .build/rodd-macos/Rodd.app
```

The generated application is local build output and is not committed.
