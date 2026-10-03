import SwiftUI

struct LinesView: View {
  let pack: PrayerPack
  let openLine: (PrayerLine) -> Void

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 6) {
          Text("Lines")
            .font(.largeTitle.weight(.semibold))
            .accessibilityAddTraits(.isHeader)
          Text("Sigrdrífumál · stanzas 3–4")
            .foregroundStyle(RoddTheme.muted)
        }
        .padding(.bottom, 8)

        ForEach(pack.orderedLines) { line in
          Button {
            openLine(line)
          } label: {
            HStack(alignment: .firstTextBaseline, spacing: 18) {
              Text("\(line.order)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(RoddTheme.lichen)
                .frame(width: 28, alignment: .trailing)
              VStack(alignment: .leading, spacing: 7) {
                Text(line.normalizedText)
                  .font(.system(.title2, design: .serif, weight: .medium))
                  .foregroundStyle(RoddTheme.ink)
                  .fixedSize(horizontal: false, vertical: true)
                Text(pack.pronunciationGuide(for: line))
                  .font(.callout)
                  .foregroundStyle(RoddTheme.muted)
                  .fixedSize(horizontal: false, vertical: true)
              }
              Spacer(minLength: 10)
              Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .roddPanel()
          .accessibilityLabel("Line \(line.order): \(line.normalizedText)")
          .accessibilityHint("Opens line practice")
        }
      }
      .frame(maxWidth: 820, alignment: .leading)
      .padding(36)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .navigationTitle("Lines")
  }
}
