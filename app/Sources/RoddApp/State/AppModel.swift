import Foundation

@MainActor
public final class AppModel: ObservableObject {
  enum ContentState: Equatable {
    case loading
    case loaded(PrayerPack)
    case failed(PrayerPackLoadError)
  }

  @Published public var selectedDestination: AppDestination = .today
  @Published var activeLineID: String?
  @Published private(set) var contentState: ContentState = .loading
  let playbackController: ReferencePlaybackController

  private let loadPack: () throws -> PrayerPack

  public convenience init() {
    self.init(autoLoad: true)
    if ProcessInfo.processInfo.arguments.contains("--line-practice") {
      beginToday()
    }
  }

  init(
    autoLoad: Bool = true,
    playbackController: ReferencePlaybackController = ReferencePlaybackController(),
    loadPack: @escaping () throws -> PrayerPack = { try PrayerPackLoader().loadBundled() }
  ) {
    self.playbackController = playbackController
    self.loadPack = loadPack
    if autoLoad {
      reloadContent()
    }
  }

  var pack: PrayerPack? {
    guard case .loaded(let pack) = contentState else { return nil }
    return pack
  }

  var activeLine: PrayerLine? {
    guard let activeLineID else { return nil }
    return pack?.orderedLines.first { $0.id == activeLineID }
  }

  func reloadContent() {
    contentState = .loading
    do {
      contentState = .loaded(try loadPack())
    } catch let error as PrayerPackLoadError {
      contentState = .failed(error)
    } catch {
      contentState = .failed(.unreadable(error.localizedDescription))
    }
  }

  public func select(_ destination: AppDestination) {
    if destination != .lines {
      playbackController.stop()
    }
    selectedDestination = destination
    if destination != .lines {
      activeLineID = nil
    }
  }

  func openLine(_ line: PrayerLine) {
    if activeLineID != line.id {
      playbackController.stop()
    }
    selectedDestination = .lines
    activeLineID = line.id
  }

  func closeLine() {
    playbackController.stop()
    activeLineID = nil
  }

  func beginToday() {
    guard let firstLine = pack?.orderedLines.first else { return }
    openLine(firstLine)
  }
}
