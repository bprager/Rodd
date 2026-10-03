import SwiftUI

enum RoddTheme {
  static let canvas = Color(red: 0.96, green: 0.94, blue: 0.89)
  static let panel = Color(red: 0.99, green: 0.98, blue: 0.95)
  static let ink = Color(red: 0.12, green: 0.12, blue: 0.10)
  static let lichen = Color(red: 0.28, green: 0.39, blue: 0.29)
  static let muted = Color(red: 0.38, green: 0.38, blue: 0.34)
  static let amber = Color(red: 0.67, green: 0.43, blue: 0.16)
}

struct RoddPanel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding(24)
      .background(RoddTheme.panel, in: RoundedRectangle(cornerRadius: 18))
      .overlay {
        RoundedRectangle(cornerRadius: 18)
          .stroke(RoddTheme.ink.opacity(0.08), lineWidth: 1)
      }
  }
}

extension View {
  func roddPanel() -> some View {
    modifier(RoddPanel())
  }
}
