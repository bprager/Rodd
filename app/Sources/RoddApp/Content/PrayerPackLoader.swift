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

    var pack: PrayerPack
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
    pack.referenceTracks = try loadReferenceTracks(for: pack, beside: file)
    return pack
  }

  private func loadReferenceTracks(for pack: PrayerPack, beside packFile: URL) throws
    -> [ReferenceTrack]
  {
    let packRoot = packFile.deletingLastPathComponent().standardizedFileURL
    let manifestURL = packRoot.appending(path: pack.referenceAudio.manifest).standardizedFileURL
    guard manifestURL.path.hasPrefix(packRoot.path + "/") else {
      throw PrayerPackLoadError.unreadable("reference-audio manifest is outside the prayer pack")
    }

    let manifest: AudioManifest
    do {
      manifest = try JSONDecoder().decode(
        AudioManifest.self,
        from: Data(contentsOf: manifestURL, options: .mappedIfSafe)
      )
    } catch {
      throw PrayerPackLoadError.unreadable(
        "reference-audio manifest: \(error.localizedDescription)")
    }

    guard manifest.contentVersion == pack.packVersion,
      manifest.contractId == pack.contractId
    else {
      throw PrayerPackLoadError.unreadable("reference audio does not match this content version")
    }

    let expected = Set(
      pack.lines.flatMap { line in
        ReferenceVoice.allCases.flatMap { voice in
          ReferenceTempoOption.allCases.map { tempo in
            AudioKey(lineID: line.id, voice: voice, tempo: tempo)
          }
        }
      }
    )
    var found = Set<AudioKey>()
    var tracks: [ReferenceTrack] = []

    for entry in manifest.entries {
      guard let voice = ReferenceVoice(rawValue: entry.style),
        let tempo = ReferenceTempoOption(rawValue: entry.tempo)
      else {
        throw PrayerPackLoadError.unreadable("reference audio has an unknown style or tempo")
      }
      let key = AudioKey(lineID: entry.lineId, voice: voice, tempo: tempo)
      guard expected.contains(key), found.insert(key).inserted else {
        throw PrayerPackLoadError.unreadable("reference audio contains an unexpected duplicate")
      }

      let audioURL = packRoot.appending(path: entry.file).standardizedFileURL
      guard audioURL.path.hasPrefix(packRoot.path + "/"),
        FileManager.default.fileExists(atPath: audioURL.path)
      else {
        throw PrayerPackLoadError.unreadable("reference audio is missing: \(entry.file)")
      }
      guard entry.contentVersion == pack.packVersion, entry.durationSeconds > 0 else {
        throw PrayerPackLoadError.unreadable("reference audio metadata is incompatible")
      }

      tracks.append(
        ReferenceTrack(
          id: entry.id,
          lineID: entry.lineId,
          voice: voice,
          tempo: tempo,
          fileURL: audioURL,
          duration: entry.durationSeconds,
          contentVersion: entry.contentVersion,
          inputTarget: entry.inputTarget
        ))
    }

    guard found == expected else {
      throw PrayerPackLoadError.unreadable("reference audio does not cover every practice line")
    }
    return tracks
  }
}

private struct AudioManifest: Decodable {
  let contentVersion: String
  let contractId: String
  let entries: [AudioManifestEntry]
}

private struct AudioManifestEntry: Decodable {
  let id: String
  let lineId: String
  let style: String
  let tempo: String
  let file: String
  let contentVersion: String
  let inputTarget: String
  let durationSeconds: Double
}

private struct AudioKey: Hashable {
  let lineID: String
  let voice: ReferenceVoice
  let tempo: ReferenceTempoOption
}
