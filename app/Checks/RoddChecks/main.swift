import Foundation
import Testing

@testable import RoddKit

@Suite("RODD-006 completion checks")
struct RoddCompletionChecks {
  @Test("The bundled prayer pack loads offline")
  func bundledPackLoads() throws {
    let pack = try PrayerPackLoader().loadBundled()
    #expect(pack.packVersion == "1.1.0")
    #expect(pack.orderedLines.map(\.order) == Array(1...8))
    #expect(pack.orderedLines.first?.normalizedText == "Heill dagr! Heilir dags synir!")
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

  private func temporaryFile(contents: Data) throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let file = directory.appending(path: "pack.json")
    try contents.write(to: file)
    return file
  }
}

@main
enum RoddChecks {
  static func main() async {
    await Testing.__swiftPMEntryPoint() as Never
  }
}
