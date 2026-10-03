import SwiftUI

public struct RootView: View {
  @ObservedObject var model: AppModel
  @AppStorage("readingSize") private var readingSize = ReadingSize.standard.rawValue

  private var preferredSize: ReadingSize {
    ReadingSize(rawValue: readingSize) ?? .standard
  }

  public init(model: AppModel) {
    self.model = model
  }

  public var body: some View {
    NavigationSplitView {
      VStack(spacing: 0) {
        List(AppDestination.allCases, selection: selection) { destination in
          Label(destination.title, systemImage: destination.symbol)
            .tag(destination)
            .accessibilityLabel(destination.title)
        }
        .listStyle(.sidebar)
        .accessibilityLabel("Practice sections")

        Divider()
        SettingsLink {
          Label("Settings", systemImage: "gearshape")
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(",", modifiers: .command)
        .padding(14)
        .accessibilityHint("Opens profile, session, and text-size settings")
      }
      .navigationTitle("Rǫdd")
      .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 270)
    } detail: {
      content
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoddTheme.canvas)
    }
    .environment(\.dynamicTypeSize, preferredSize.dynamicTypeSize)
    .tint(RoddTheme.lichen)
    #if DEBUG
      .task {
        await AccessibilitySelfAudit.runIfRequested()
      }
    #endif
  }

  private var selection: Binding<AppDestination?> {
    Binding(
      get: { model.selectedDestination },
      set: { destination in
        if let destination { model.select(destination) }
      }
    )
  }

  @ViewBuilder
  private var content: some View {
    switch model.contentState {
    case .loading:
      ProgressView("Loading teaching content…")
        .accessibilityLabel("Loading teaching content")
    case .failed(let error):
      ContentRecoveryView(error: error, retry: model.reloadContent)
    case .loaded(let pack):
      destinationView(pack: pack)
    }
  }

  @ViewBuilder
  private func destinationView(pack: PrayerPack) -> some View {
    switch model.selectedDestination {
    case .today:
      TodayView(pack: pack, begin: model.beginToday)
    case .lines:
      if let line = model.activeLine {
        LinePracticeView(
          pack: pack,
          line: line,
          close: { model.activeLineID = nil },
          openLine: model.openLine
        )
      } else {
        LinesView(pack: pack, openLine: model.openLine)
      }
    case .sounds:
      PlaceholderDestinationView(
        title: "Sounds",
        symbol: "waveform",
        message:
          "Focused listening and mouth-position workshops will appear here after the practice foundation is complete."
      )
    case .recite:
      PlaceholderDestinationView(
        title: "Recite",
        symbol: "mic",
        message:
          "Full, uninterrupted recitation practice will build on the recording and assessment milestones."
      )
    case .progress:
      PlaceholderDestinationView(
        title: "Progress",
        symbol: "chart.line.uptrend.xyaxis",
        message: "Private, local progress will appear here once practice history is available."
      )
    }
  }
}

struct ContentRecoveryView: View {
  let error: PrayerPackLoadError
  let retry: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("Teaching content unavailable", systemImage: "books.vertical")
    } description: {
      VStack(spacing: 8) {
        Text(error.errorDescription ?? "Rǫdd could not load its teaching content.")
        Text(error.recoverySuggestion ?? "Try again or reinstall Rǫdd.")
      }
    } actions: {
      Button("Try Again", action: retry)
        .keyboardShortcut(.defaultAction)
    }
    .accessibilityElement(children: .contain)
  }
}
