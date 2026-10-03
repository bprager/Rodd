import Foundation
import SwiftUI

struct PrayerPack: Decodable, Equatable, Sendable {
  let packVersion: String
  let contractId: String
  let work: String
  let profile: PronunciationProfile
  let referenceAudio: ReferenceAudioConfiguration
  let lexicon: [LexiconEntry]
  let lines: [PrayerLine]

  var orderedLines: [PrayerLine] {
    lines.sorted { $0.order < $1.order }
  }

  func pronunciationGuide(for line: PrayerLine) -> String {
    let entries = Dictionary(uniqueKeysWithValues: lexicon.map { ($0.id, $0) })
    return line.tokenIds.compactMap { entries[$0]?.canonicalIpa }.joined(separator: "  ")
  }
}

struct PronunciationProfile: Decodable, Equatable, Sendable {
  let id: String
  let label: String
  let description: String
}

struct ReferenceAudioConfiguration: Decodable, Equatable, Sendable {
  let styles: [String: ReferenceStyle]
  let tempos: [String: ReferenceTempo]
}

struct ReferenceStyle: Decodable, Equatable, Sendable {
  let label: String
  let purpose: String
  let limitation: String
}

struct ReferenceTempo: Decodable, Equatable, Sendable {
  let label: String
  let purpose: String
}

struct LexiconEntry: Decodable, Equatable, Identifiable, Sendable {
  let id: String
  let surface: String
  let normalized: String
  let canonicalIpa: String
  let teachingNotes: [String]
}

struct PrayerLine: Decodable, Equatable, Identifiable, Hashable, Sendable {
  let id: String
  let order: Int
  let stanza: Int
  let editionText: String
  let normalizedText: String
  let tokenIds: [String]
}

public enum AppDestination: String, CaseIterable, Identifiable, Sendable {
  case today
  case lines
  case sounds
  case recite
  case progress

  public var id: Self { self }

  public var title: String {
    switch self {
    case .today: "Today"
    case .lines: "Lines"
    case .sounds: "Sounds"
    case .recite: "Recite"
    case .progress: "Progress"
    }
  }

  var symbol: String {
    switch self {
    case .today: "sun.max"
    case .lines: "text.quote"
    case .sounds: "waveform"
    case .recite: "mic"
    case .progress: "chart.line.uptrend.xyaxis"
    }
  }

  public var keyboardNumber: KeyEquivalent {
    switch self {
    case .today: "1"
    case .lines: "2"
    case .sounds: "3"
    case .recite: "4"
    case .progress: "5"
    }
  }
}

enum ReadingSize: String, CaseIterable, Identifiable, Sendable {
  case standard
  case large
  case extraLarge

  var id: Self { self }

  var title: String {
    switch self {
    case .standard: "Standard"
    case .large: "Large"
    case .extraLarge: "Extra Large"
    }
  }

  var dynamicTypeSize: DynamicTypeSize {
    switch self {
    case .standard: .large
    case .large: .xxLarge
    case .extraLarge: .accessibility2
    }
  }
}
