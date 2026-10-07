import Foundation
import Testing

@testable import RoddKit

@Suite("RODD-006 and RODD-007 completion checks")
struct RoddCompletionChecks {
  @Test("The bundled prayer pack loads offline")
  func bundledPackLoads() throws {
    let pack = try PrayerPackLoader().loadBundled()
    #expect(pack.packVersion == "1.1.0")
    #expect(pack.orderedLines.map(\.order) == Array(1...8))
    #expect(pack.orderedLines.first?.normalizedText == "Heill dagr! Heilir dags synir!")
    #expect(pack.referenceTracks.count == 32)
  }

  @Test("Missing content provides recovery guidance")
  func missingPack() {
    let file = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString)
      .appending(path: "pack.json")

    #expect(throws: PrayerPackLoadError.missing) {
      try PrayerPackLoader().load(file: file)
    }
    #expect(PrayerPackLoadError.missing.recoverySuggestion?.contains("Reinstall") == true)
  }

  @Test("Damaged content is rejected")
  func damagedPack() throws {
    let file = try temporaryFile(contents: Data("not json".utf8))
    #expect(throws: PrayerPackLoadError.self) {
      try PrayerPackLoader().load(file: file)
    }
  }

  @Test("An incompatible future pack is rejected")
  func incompatiblePack() throws {
    let bundled = try PrayerPackLoader().bundledFileURL()
    let current = try String(contentsOf: bundled, encoding: .utf8)
    let future = current.replacingOccurrences(
      of: #""packVersion": "1.1.0""#,
      with: #""packVersion": "2.0.0""#
    )
    let file = try temporaryFile(contents: Data(future.utf8))

    #expect(throws: PrayerPackLoadError.incompatible("2.0.0")) {
      try PrayerPackLoader().load(file: file)
    }
  }

  @MainActor
  @Test("The app starts on Today")
  func startsOnToday() {
    let model = AppModel(autoLoad: false)
    #expect(model.selectedDestination == .today)
  }

  @MainActor
  @Test("Beginning Today opens the first line")
  func beginningTodayOpensFirstLine() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let model = AppModel(loadPack: { pack })

    model.beginToday()

    #expect(model.selectedDestination == .lines)
    #expect(model.activeLine?.order == 1)
  }

  @MainActor
  @Test("A content failure reaches the recovery state")
  func failedContentHasRecoveryState() {
    let model = AppModel(loadPack: { throw PrayerPackLoadError.missing })

    guard case .failed(let error) = model.contentState else {
      Issue.record("Expected the content recovery state")
      return
    }
    #expect(error == .missing)
    #expect(error.errorDescription?.isEmpty == false)
    #expect(error.recoverySuggestion?.isEmpty == false)
  }

  @Test("Every sidebar destination has a distinct keyboard route")
  func keyboardNavigation() {
    #expect(AppDestination.allCases.count == 5)
    #expect(AppDestination.allCases.allSatisfy { !$0.title.isEmpty && !$0.symbol.isEmpty })
    #expect(Set(AppDestination.allCases.map(\.keyboardNumber)).count == 5)
  }

  @Test("The supported reading range reaches accessibility sizes")
  func readingSizesScale() {
    #expect(ReadingSize.allCases.count == 3)
    #expect(ReadingSize.extraLarge.dynamicTypeSize.isAccessibilitySize)
  }

  @Test("Both references disclose purpose and limitations")
  func referenceLabels() throws {
    let styles = try PrayerPackLoader().loadBundled().referenceAudio.styles
    #expect(Set(styles.keys) == ["precise", "naturalized"])
    #expect(
      styles.values.allSatisfy {
        !$0.label.isEmpty && !$0.purpose.isEmpty && !$0.limitation.isEmpty
      })
  }

  @MainActor
  @Test("Starting another reference stops the first one")
  func playbackIsExclusive() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let line = try #require(pack.orderedLines.first)
    let precise = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural)
    )
    let naturalized = try #require(
      pack.referenceTrack(lineID: line.id, voice: .naturalized, tempo: .natural)
    )
    let engine = FakeAudioEngine()
    let announcer = RecordingAnnouncer()
    let controller = ReferencePlaybackController(engine: engine, announcer: announcer)

    controller.play(precise, styleLabel: "Precise", tempoLabel: "Natural")
    controller.play(naturalized, styleLabel: "Naturalized", tempoLabel: "Natural")

    #expect(engine.playedFiles == [precise.fileURL, naturalized.fileURL])
    #expect(controller.isPlaying(naturalized))
    #expect(!controller.isPlaying(precise))
    #expect(announcer.messages.last?.contains("Naturalized") == true)
  }

  @MainActor
  @Test("Toggling the active reference stops it")
  func playbackToggleStops() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let line = try #require(pack.orderedLines.first)
    let track = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural)
    )
    let engine = FakeAudioEngine()
    let controller = ReferencePlaybackController(
      engine: engine,
      announcer: RecordingAnnouncer()
    )

    controller.toggle(track, styleLabel: "Precise", tempoLabel: "Natural")
    controller.toggle(track, styleLabel: "Precise", tempoLabel: "Natural")

    #expect(!controller.isPlaying)
    #expect(controller.statusMessage == "Reference playback stopped.")
  }

  @MainActor
  @Test("Changing tempo swaps to the recorded teaching file")
  func tempoChangeUsesRecordedFile() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let line = try #require(pack.orderedLines.first)
    let natural = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural)
    )
    let teaching = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .teaching)
    )
    let engine = FakeAudioEngine()
    let controller = ReferencePlaybackController(
      engine: engine,
      announcer: RecordingAnnouncer()
    )

    controller.play(natural, styleLabel: "Precise", tempoLabel: "Natural")
    controller.changeTempo(to: .teaching, for: line, in: pack)

    #expect(controller.activeTrack == teaching)
    #expect(engine.playedFiles.last == teaching.fileURL)
    #expect(natural.fileURL != teaching.fileURL)
  }

  @MainActor
  @Test("Playback completion is visible and announced")
  func completionIsAnnounced() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let line = try #require(pack.orderedLines.first)
    let track = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural)
    )
    let engine = FakeAudioEngine()
    let announcer = RecordingAnnouncer()
    let controller = ReferencePlaybackController(engine: engine, announcer: announcer)

    controller.play(track, styleLabel: "Precise", tempoLabel: "Natural")
    engine.finish()

    #expect(controller.phase == .idle)
    #expect(controller.statusMessage == "Reference playback finished.")
    #expect(announcer.messages.last == controller.statusMessage)
  }

  @MainActor
  @Test("An output change continues playback and is announced")
  func outputChangeContinues() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let line = try #require(pack.orderedLines.first)
    let track = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural)
    )
    let engine = FakeAudioEngine()
    let announcer = RecordingAnnouncer()
    let controller = ReferencePlaybackController(engine: engine, announcer: announcer)
    controller.play(track, styleLabel: "Precise", tempoLabel: "Natural")

    engine.reportOutputChange(failure: nil)

    #expect(controller.isPlaying(track))
    #expect(controller.statusMessage.contains("new output"))
    #expect(announcer.messages.last == controller.statusMessage)
  }

  @MainActor
  @Test("An output recovery failure stops with guidance")
  func outputFailureStops() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let line = try #require(pack.orderedLines.first)
    let track = try #require(
      pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural)
    )
    let engine = FakeAudioEngine()
    let controller = ReferencePlaybackController(
      engine: engine,
      announcer: RecordingAnnouncer()
    )
    controller.play(track, styleLabel: "Precise", tempoLabel: "Natural")

    engine.reportOutputChange(failure: "Select another output and try again.")

    guard case .failed(let message) = controller.phase else {
      Issue.record("Expected a visible playback failure")
      return
    }
    #expect(message.contains("playback stopped"))
    #expect(!controller.isPlaying)
  }

  @Test("All teaching tracks passed the recorded pitch-preservation analysis")
  func teachingTempoPreservesPitch() throws {
    let loader = PrayerPackLoader()
    let pack = try loader.loadBundled()
    let packRoot = try loader.bundledFileURL().deletingLastPathComponent()
    let data = try Data(contentsOf: packRoot.appending(path: pack.referenceAudio.analysis))
    let analysis = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    let pairs = try #require(analysis["pairs"] as? [[String: Any]])

    #expect(analysis["allPitchPreserved"] as? Bool == true)
    #expect(analysis["allTempoVerified"] as? Bool == true)
    #expect(pairs.count == 16)
    #expect(
      pairs.allSatisfy {
        guard let cents = $0["pitchDifferenceCents"] as? Double else { return false }
        return abs(cents) <= 80
      })
  }

  private func temporaryFile(contents: Data) throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let file = directory.appending(path: "pack.json")
    try contents.write(to: file)
    return file
  }
}

@MainActor
private final class FakeAudioEngine: AudioPlaybackEngine {
  var onFinished: (() -> Void)?
  var onDecodeError: ((String) -> Void)?
  var onOutputChanged: ((String?) -> Void)?
  var isPlaying = false
  var currentTime: TimeInterval = 0
  var duration: TimeInterval = 5
  var playedFiles: [URL] = []

  func play(file: URL) throws {
    playedFiles.append(file)
    currentTime = 0
    isPlaying = true
  }

  func stop() {
    isPlaying = false
    currentTime = 0
  }

  func finish() {
    isPlaying = false
    currentTime = duration
    onFinished?()
  }

  func reportOutputChange(failure: String?) {
    onOutputChanged?(failure)
  }
}

@MainActor
private final class RecordingAnnouncer: PlaybackAnnouncing {
  private(set) var messages: [String] = []

  func announce(_ message: String) {
    messages.append(message)
  }
}

@main
enum RoddChecks {
  static func main() async {
    await Testing.__swiftPMEntryPoint() as Never
  }
}
