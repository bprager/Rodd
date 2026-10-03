import RoddKit
import SwiftUI

@main
struct RoddApplication: App {
  @StateObject private var model = AppModel()

  var body: some Scene {
    WindowGroup {
      RootView(model: model)
        .frame(minWidth: 720, minHeight: 520)
    }
    .defaultSize(width: 1040, height: 720)
    .commands {
      CommandMenu("Navigate") {
        ForEach(AppDestination.allCases) { destination in
          Button(destination.title) {
            model.select(destination)
          }
          .keyboardShortcut(destination.keyboardNumber, modifiers: .command)
        }
      }
    }

    Settings {
      SettingsView(model: model)
    }
  }
}
