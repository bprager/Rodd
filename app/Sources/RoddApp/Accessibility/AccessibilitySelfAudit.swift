#if DEBUG
  import AppKit
  import ApplicationServices

  @MainActor
  enum AccessibilitySelfAudit {
    static func runIfRequested() async {
      guard ProcessInfo.processInfo.arguments.contains("--accessibility-audit") else { return }
      try? await Task.sleep(for: .seconds(1))

      let application = AXUIElementCreateApplication(getpid())
      let descriptions = collect(from: application)
      var required = ["Today", "Lines", "Sounds", "Recite", "Progress", "Settings"]
      if ProcessInfo.processInfo.arguments.contains("--line-practice") {
        required += ["All lines", "Line 1 of 8", "Reference styles", "Next line"]
      } else {
        required += ["Today’s practice", "Begin"]
      }
      let missing = required.filter { expected in
        !descriptions.contains { $0.localizedCaseInsensitiveContains(expected) }
      }

      if missing.isEmpty {
        print("ACCESSIBILITY AUDIT PASSED: \(descriptions.count) labeled or valued elements")
        NSApplication.shared.terminate(nil)
      } else {
        print("ACCESSIBILITY AUDIT FAILED: missing \(missing.joined(separator: ", "))")
        for description in descriptions.sorted() {
          print("AX: \(description)")
        }
        exit(1)
      }
    }

    private static func collect(from root: AXUIElement) -> [String] {
      var queue = [root]
      var descriptions: [String] = []
      var visited = 0

      while !queue.isEmpty, visited < 500 {
        let element = queue.removeFirst()
        visited += 1

        let pieces = [
          stringValue(of: kAXRoleAttribute, in: element),
          stringValue(of: kAXTitleAttribute, in: element),
          stringValue(of: kAXDescriptionAttribute, in: element),
          stringValue(of: kAXHelpAttribute, in: element),
          stringValue(of: kAXValueAttribute, in: element),
        ].compactMap { $0 }.filter { !$0.isEmpty }
        if !pieces.isEmpty {
          descriptions.append(pieces.joined(separator: " · "))
        }

        queue.append(contentsOf: children(of: element))
      }
      return descriptions
    }

    private static func stringValue(of attribute: String, in element: AXUIElement) -> String? {
      var value: CFTypeRef?
      guard AXUIElementCopyAttributeValue(element, attribute as CFString, &value) == .success else {
        return nil
      }
      if let string = value as? String { return string }
      if let number = value as? NSNumber { return number.stringValue }
      return nil
    }

    private static func children(of element: AXUIElement) -> [AXUIElement] {
      var value: CFTypeRef?
      guard
        AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &value)
          == .success,
        let children = value as? [AXUIElement]
      else {
        return []
      }
      return children
    }
  }
#endif
