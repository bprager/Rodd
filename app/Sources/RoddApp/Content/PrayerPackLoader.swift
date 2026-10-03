import Foundation

enum PrayerPackLoadError: LocalizedError, Equatable {
  case missing
  case unreadable(String)
  case incompatible(String)

  var errorDescription: String? {
    switch self {
    case .missing:
      "The Sigrdrífumál prayer pack is missing."
    case .unreadable:
      "The Sigrdrífumál prayer pack could not be read."
    case .incompatible(let version):
      "Prayer pack version \(version) is not supported by this version of Rǫdd."
    }
  }

  var recoverySuggestion: String? {
    switch self {
    case .missing:
      "Reinstall Rǫdd to restore its built-in teaching content, then try again."
    case .unreadable(let detail):
      "The content may be damaged (\(detail)). Reinstall Rǫdd, then try again."
    case .incompatible:
      "Update Rǫdd or reinstall the matching built-in content, then try again."
    }
  }
}

struct PrayerPackLoader: Sendable {
  static let supportedMajorVersion = 1
  static let resourceDirectory = "sigrdrifumal-west-norse-ca-1200"

  private var resourceBundle: Bundle {
    if let packagedURL = Bundle.main.url(forResource: "Rodd_RoddKit", withExtension: "bundle"),
      let packagedBundle = Bundle(url: packagedURL)
    {
      return packagedBundle
    }
    return Bundle.module
  }

  func loadBundled() throws -> PrayerPack {
    return try load(file: bundledFileURL())
  }

  func bundledFileURL() throws -> URL {
    guard
      let file = resourceBundle.url(
        forResource: "pack",
        withExtension: "json",
        subdirectory: Self.resourceDirectory
      )
    else {
      throw PrayerPackLoadError.missing
    }
    return file
  }

  func load(file: URL) throws -> PrayerPack {
    guard FileManager.default.fileExists(atPath: file.path) else {
      throw PrayerPackLoadError.missing
    }

    let data: Data
    do {
      data = try Data(contentsOf: file, options: .mappedIfSafe)
    } catch {
      throw PrayerPackLoadError.unreadable(error.localizedDescription)
    }

    let pack: PrayerPack
    do {
      pack = try JSONDecoder().decode(PrayerPack.self, from: data)
    } catch {
      throw PrayerPackLoadError.unreadable(error.localizedDescription)
    }

    guard let major = Int(pack.packVersion.split(separator: ".").first ?? ""),
      major == Self.supportedMajorVersion
    else {
      throw PrayerPackLoadError.incompatible(pack.packVersion)
    }
    guard pack.orderedLines.count == 8 else {
      throw PrayerPackLoadError.unreadable("expected eight practice lines")
    }
    return pack
  }
}
