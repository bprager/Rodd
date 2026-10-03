import Testing

@testable import RoddKit

@MainActor
@Suite("macOS application shell")
struct AppShellTests {
  @Test("The app always starts on Today")
  func startsOnToday() {
    let model = AppModel(autoLoad: false)
    #expect(model.selectedDestination == .today)
  }

  @Test("Beginning Today opens the first line")
  func beginningTodayOpensFirstLine() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let model = AppModel(loadPack: { pack })
    model.beginToday()
    #expect(model.selectedDestination == .lines)
    #expect(model.activeLine?.order == 1)
  }

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

  @Test("All sidebar destinations have visible and keyboard names")
  func sidebarDestinationsAreDescribed() {
    #expect(AppDestination.allCases.count == 5)
    #expect(AppDestination.allCases.allSatisfy { !$0.title.isEmpty && !$0.symbol.isEmpty })
    #expect(Set(AppDestination.allCases.map(\.keyboardNumber)).count == 5)
  }

  @Test("Supported reading sizes include an accessibility size")
  func readingSizesScale() {
    #expect(ReadingSize.allCases.count == 3)
    #expect(ReadingSize.extraLarge.dynamicTypeSize.isAccessibilitySize)
  }

  @Test("Reference styles disclose their purpose and limitations")
  func referenceStyleLabels() throws {
    let pack = try PrayerPackLoader().loadBundled()
    let styles = pack.referenceAudio.styles

    #expect(Set(styles.keys) == ["precise", "naturalized"])
    #expect(
      styles.values.allSatisfy {
        !$0.label.isEmpty && !$0.purpose.isEmpty && !$0.limitation.isEmpty
      })
  }
}
