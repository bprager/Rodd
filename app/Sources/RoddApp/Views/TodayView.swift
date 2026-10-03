import SwiftUI

struct TodayView: View {
  let pack: PrayerPack
  let begin: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 28) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Today’s practice")
            .font(.largeTitle.weight(.semibold))
            .foregroundStyle(RoddTheme.ink)
            .accessibilityAddTraits(.isHeader)
          Text("A calm first pass through the greeting")
            .font(.title3)
            .foregroundStyle(RoddTheme.muted)
        }

        VStack(alignment: .leading, spacing: 20) {
          Label("8 lines · listening and orientation · about 7 minutes", systemImage: "clock")
            .font(.headline)

          Divider()

          Text(pack.orderedLines.first?.normalizedText ?? pack.work)
            .font(.system(.title, design: .serif, weight: .medium))
            .foregroundStyle(RoddTheme.ink)
            .textSelection(.enabled)
            .accessibilityLabel(
              "First line: \(pack.orderedLines.first?.normalizedText ?? pack.work)")

          Text(
            "Begin with the declared \(pack.profile.label) profile. Rǫdd will keep historical uncertainty visible rather than treating one reading as uniquely knowable."
          )
          .foregroundStyle(RoddTheme.muted)
          .fixedSize(horizontal: false, vertical: true)

          Button(action: begin) {
            Label("Begin", systemImage: "arrow.right")
              .frame(minWidth: 150)
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .keyboardShortcut(.defaultAction)
          .accessibilityHint("Opens line 1 in line practice")
        }
        .roddPanel()

        HStack(alignment: .top, spacing: 18) {
          SummaryItem(
            symbol: "shield", title: "Private",
            text: "Content and future practice data remain on this Mac.")
          SummaryItem(
            symbol: "book.closed", title: "Documented",
            text: "The teaching profile and its limits stay visible.")
        }
      }
      .frame(maxWidth: 760, alignment: .leading)
      .padding(40)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .navigationTitle("Today")
  }
}

private struct SummaryItem: View {
  let symbol: String
  let title: String
  let text: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Image(systemName: symbol)
        .font(.title2)
        .foregroundStyle(RoddTheme.lichen)
        .accessibilityHidden(true)
      Text(title)
        .font(.headline)
      Text(text)
        .foregroundStyle(RoddTheme.muted)
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .roddPanel()
    .accessibilityElement(children: .combine)
  }
}
