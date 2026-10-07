import SwiftUI

struct LinePracticeView: View {
  let pack: PrayerPack
  let line: PrayerLine
  @ObservedObject var playbackController: ReferencePlaybackController
  let close: () -> Void
  let openLine: (PrayerLine) -> Void

  private var previous: PrayerLine? {
    pack.orderedLines.last { $0.order == line.order - 1 }
  }

  private var next: PrayerLine? {
    pack.orderedLines.first { $0.order == line.order + 1 }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Button(action: close) {
          Label("All lines", systemImage: "chevron.left")
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.cancelAction)

        HStack(alignment: .firstTextBaseline) {
          Text("Line \(line.order) of \(pack.orderedLines.count)")
            .font(.headline)
            .foregroundStyle(RoddTheme.muted)
          Spacer()
          Text(playbackController.statusMessage)
            .font(.callout.weight(.medium))
            .foregroundStyle(RoddTheme.lichen)
            .lineLimit(2)
            .accessibilityLabel("Playback status: \(playbackController.statusMessage)")
        }

        VStack(alignment: .leading, spacing: 16) {
          Text(line.normalizedText)
            .font(.system(.largeTitle, design: .serif, weight: .medium))
            .foregroundStyle(RoddTheme.ink)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)

          Text(pack.pronunciationGuide(for: line))
            .font(.title3)
            .foregroundStyle(RoddTheme.muted)
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("Pronunciation guide: \(pack.pronunciationGuide(for: line))")
        }
        .roddPanel()

        ReferencePlaybackView(
          pack: pack,
          line: line,
          controller: playbackController
        )

        HStack {
          if let previous {
            Button("Previous line") { openLine(previous) }
          }
          Spacer()
          if let next {
            Button("Next line") { openLine(next) }
              .keyboardShortcut(.defaultAction)
          }
        }
      }
      .frame(maxWidth: 820, alignment: .leading)
      .padding(36)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .navigationTitle("Line \(line.order)")
    .onDisappear {
      playbackController.stop()
    }
  }
}
