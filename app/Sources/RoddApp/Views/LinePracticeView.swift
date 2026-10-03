import SwiftUI

struct LinePracticeView: View {
  let pack: PrayerPack
  let line: PrayerLine
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
          Text("Ready to practice")
            .font(.callout.weight(.medium))
            .foregroundStyle(RoddTheme.lichen)
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

        ReferencePreview(pack: pack)

        VStack(alignment: .leading, spacing: 10) {
          Text("Practice controls")
            .font(.headline)
          Text(
            "This foundation is ready for reference playback and recording. Those controls arrive in the next two milestones, after their behavior can be tested honestly."
          )
          .foregroundStyle(RoddTheme.muted)
          .fixedSize(horizontal: false, vertical: true)
        }
        .roddPanel()

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
  }
}

private struct ReferencePreview: View {
  let pack: PrayerPack

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Reference styles")
        .font(.headline)
      ForEach(["precise", "naturalized"], id: \.self) { key in
        if let style = pack.referenceAudio.styles[key] {
          VStack(alignment: .leading, spacing: 5) {
            Text(style.label)
              .font(.subheadline.weight(.semibold))
            Text(style.purpose)
            Text(style.limitation)
              .foregroundStyle(RoddTheme.muted)
          }
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityElement(children: .combine)
        }
      }
    }
    .roddPanel()
  }
}
