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
- [macOS app-shell verification](docs/macos-app-shell-verification.md)
- [Versioned teaching content](content/README.md)
- [Prioritized backlog](BACKLOG.md)
- [Changelog](Changelog.md)

## Current status

Pronunciation Contract v1, prayer pack 1.1.0, and the native macOS application
shell are complete. The app opens to Today, navigates through the planned
sections, loads all eight lines offline, and provides a native Settings window.
The next milestone is reference playback.

## Build and verify the macOS app

Rǫdd requires macOS 14 or later and Apple’s command-line developer tools. The
build script creates an ad-hoc-signed application and runs the shell checks:

```sh
scripts/build_macos_app.sh
open .build/rodd-macos/Rodd.app
```

The generated application is local build output and is not committed.
