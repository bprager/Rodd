import Foundation
import Testing

@testable import RoddKit

@Suite("Offline prayer-pack loader")
struct PrayerPackLoaderTests {
  @Test("The bundled pack loads without a network dependency")
  func bundledPackLoads() throws {
    let pack = try PrayerPackLoader().loadBundled()

    #expect(pack.packVersion == "1.1.0")
    #expect(pack.orderedLines.map(\.order) == Array(1...8))
    #expect(pack.orderedLines.first?.normalizedText == "Heill dagr! Heilir dags synir!")
  }

  @Test("A missing pack has a useful recovery path")
  func missingPack() {
    let file = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString)
      .appending(path: "pack.json")

    #expect(throws: PrayerPackLoadError.missing) {
      try PrayerPackLoader().load(file: file)
    }
  }

  @Test("Damaged content is rejected")
  func damagedPack() throws {
    let file = try temporaryFile(contents: Data("not json".utf8))

    #expect(throws: PrayerPackLoadError.self) {
      try PrayerPackLoader().load(file: file)
    }
  }

  @Test("A future incompatible content version is rejected")
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

  private func temporaryFile(contents: Data) throws -> URL {
    let directory = FileManager.default.temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let file = directory.appending(path: "pack.json")
    try contents.write(to: file)
    return file
  }
}
