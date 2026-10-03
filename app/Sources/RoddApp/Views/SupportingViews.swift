import SwiftUI

struct PlaceholderDestinationView: View {
  let title: String
  let symbol: String
  let message: String

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Image(systemName: symbol)
          .font(.system(size: 38, weight: .light))
          .foregroundStyle(RoddTheme.lichen)
          .accessibilityHidden(true)
        Text(title)
          .font(.largeTitle.weight(.semibold))
          .accessibilityAddTraits(.isHeader)
        Text(message)
          .font(.title3)
          .foregroundStyle(RoddTheme.muted)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: 620, alignment: .leading)
      .roddPanel()
      .padding(40)
      .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    .navigationTitle(title)
  }
}

public struct SettingsView: View {
  @ObservedObject var model: AppModel
  @AppStorage("readingSize") private var readingSize = ReadingSize.standard.rawValue
  @AppStorage("sessionMinutes") private var sessionMinutes = 7

  public init(model: AppModel) {
    self.model = model
  }

  public var body: some View {
    Form {
      Section("Practice") {
        Picker("Default session", selection: $sessionMinutes) {
          Text("5 minutes").tag(5)
          Text("7 minutes").tag(7)
          Text("10 minutes").tag(10)
        }
        .pickerStyle(.menu)

        Picker("Reading size", selection: $readingSize) {
          ForEach(ReadingSize.allCases) { size in
            Text(size.title).tag(size.rawValue)
          }
        }
        .pickerStyle(.segmented)
        .accessibilityHint("Changes text throughout the main window")
      }

      Section("Pronunciation profile") {
        LabeledContent("Profile", value: model.pack?.profile.label ?? "Unavailable")
        LabeledContent("Content version", value: model.pack?.packVersion ?? "Unavailable")
        Text("Rǫdd teaches one documented reconstruction and keeps its uncertainty visible.")
          .foregroundStyle(.secondary)
      }

      Section("Privacy") {
        Label(
          "Teaching content is bundled and loads without a network connection.", systemImage: "lock"
        )
      }
    }
    .formStyle(.grouped)
    .padding()
    .frame(minWidth: 520, minHeight: 390)
  }
}
