import AVFoundation
import AppKit
import CoreAudio
import Foundation

@MainActor
protocol AudioPlaybackEngine: AnyObject {
  var onFinished: (() -> Void)? { get set }
  var onDecodeError: ((String) -> Void)? { get set }
  var onOutputChanged: ((String?) -> Void)? { get set }
  var isPlaying: Bool { get }
  var currentTime: TimeInterval { get }
  var duration: TimeInterval { get }

  func play(file: URL) throws
  func stop()
}

@MainActor
protocol PlaybackAnnouncing: AnyObject {
  func announce(_ message: String)
}

@MainActor
final class ReferencePlaybackController: ObservableObject {
  enum Phase: Equatable {
    case idle
    case playing(ReferenceTrack)
    case failed(String)
  }

  @Published private(set) var phase: Phase = .idle
  @Published private(set) var statusMessage = "Ready to play a reference."
  @Published private(set) var elapsed: TimeInterval = 0
  @Published private(set) var duration: TimeInterval = 0
  @Published var selectedTempo: ReferenceTempoOption = .natural

  private let engine: AudioPlaybackEngine
  private let announcer: PlaybackAnnouncing
  private var progressTask: Task<Void, Never>?

  init(
    engine: AudioPlaybackEngine = AVAudioFilePlaybackEngine(),
    announcer: PlaybackAnnouncing = AppPlaybackAnnouncer()
  ) {
    self.engine = engine
    self.announcer = announcer
    engine.onFinished = { [weak self] in
      self?.finishPlayback()
    }
    engine.onDecodeError = { [weak self] message in
      self?.fail(message)
    }
    engine.onOutputChanged = { [weak self] failure in
      self?.handleOutputChange(failure: failure)
    }
  }

  var activeTrack: ReferenceTrack? {
    guard case .playing(let track) = phase else { return nil }
    return track
  }

  var isPlaying: Bool {
    activeTrack != nil && engine.isPlaying
  }

  func isPlaying(_ track: ReferenceTrack) -> Bool {
    activeTrack?.id == track.id && engine.isPlaying
  }

  func toggle(_ track: ReferenceTrack, styleLabel: String, tempoLabel: String) {
    if isPlaying(track) {
      stop(announcement: "Reference playback stopped.")
    } else {
      play(track, styleLabel: styleLabel, tempoLabel: tempoLabel)
    }
  }

  func play(_ track: ReferenceTrack, styleLabel: String, tempoLabel: String) {
    progressTask?.cancel()
    engine.stop()
    do {
      try engine.play(file: track.fileURL)
      phase = .playing(track)
      elapsed = 0
      duration = engine.duration
      statusMessage = "Playing \(styleLabel) · \(tempoLabel)"
      announcer.announce(statusMessage)
      startProgressUpdates()
    } catch {
      fail("Could not play this reference. \(error.localizedDescription)")
    }
  }

  func changeTempo(
    to tempo: ReferenceTempoOption,
    for line: PrayerLine,
    in pack: PrayerPack
  ) {
    guard selectedTempo != tempo else { return }
    selectedTempo = tempo
    guard let voice = activeTrack?.voice else { return }
    guard let replacement = pack.referenceTrack(lineID: line.id, voice: voice, tempo: tempo),
      let style = pack.referenceAudio.styles[voice.rawValue],
      let tempoDescription = pack.referenceAudio.tempos[tempo.rawValue]
    else {
      fail("The selected reference is unavailable.")
      return
    }
    play(
      replacement,
      styleLabel: style.label,
      tempoLabel: tempoDescription.label
    )
  }

  func stop(announcement: String? = nil) {
    progressTask?.cancel()
    progressTask = nil
    engine.stop()
    phase = .idle
    elapsed = 0
    duration = 0
    statusMessage = announcement ?? "Ready to play a reference."
    if let announcement {
      announcer.announce(announcement)
    }
  }

  private func finishPlayback() {
    guard activeTrack != nil else { return }
    progressTask?.cancel()
    progressTask = nil
    elapsed = duration
    phase = .idle
    statusMessage = "Reference playback finished."
    announcer.announce(statusMessage)
  }

  private func fail(_ message: String) {
    progressTask?.cancel()
    progressTask = nil
    engine.stop()
    phase = .failed(message)
    statusMessage = message
    announcer.announce(message)
  }

  private func handleOutputChange(failure: String?) {
    guard activeTrack != nil else { return }
    if let failure {
      fail("Audio output changed and playback stopped. \(failure)")
    } else {
      statusMessage = "Audio output changed. Playback continued on the new output."
      announcer.announce(statusMessage)
    }
  }

  private func startProgressUpdates() {
    progressTask = Task { @MainActor [weak self] in
      while !Task.isCancelled {
        try? await Task.sleep(for: .milliseconds(100))
        guard let self, !Task.isCancelled else { return }
        elapsed = min(engine.currentTime, duration)
      }
    }
  }
}

@MainActor
final class AVAudioFilePlaybackEngine: NSObject, AudioPlaybackEngine, AVAudioPlayerDelegate {
  var onFinished: (() -> Void)?
  var onDecodeError: ((String) -> Void)?
  var onOutputChanged: ((String?) -> Void)?

  private var player: AVAudioPlayer?
  private var outputMonitor: DefaultOutputMonitor?
  private let volume: Float

  init(volume: Float = 1) {
    self.volume = volume
    super.init()
    outputMonitor = DefaultOutputMonitor { [weak self] in
      Task { @MainActor in
        self?.restartAfterOutputChange()
      }
    }
  }

  var isPlaying: Bool { player?.isPlaying == true }
  var currentTime: TimeInterval { player?.currentTime ?? 0 }
  var duration: TimeInterval { player?.duration ?? 0 }

  func play(file: URL) throws {
    let replacement = try makePlayer(file: file)
    player?.stop()
    player = replacement
    guard replacement.play() else {
      player = nil
      throw PlaybackError.couldNotStart
    }
  }

  func stop() {
    player?.stop()
    player = nil
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    guard player === self.player else { return }
    self.player = nil
    if flag {
      onFinished?()
    } else {
      onDecodeError?("The audio decoder stopped before the reference finished.")
    }
  }

  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    guard player === self.player else { return }
    self.player = nil
    onDecodeError?(error?.localizedDescription ?? "The reference audio could not be decoded.")
  }

  func simulateOutputChangeForVerification() {
    restartAfterOutputChange()
  }

  private func makePlayer(file: URL) throws -> AVAudioPlayer {
    let player = try AVAudioPlayer(contentsOf: file)
    player.delegate = self
    player.volume = volume
    guard player.prepareToPlay() else {
      throw PlaybackError.couldNotPrepare
    }
    return player
  }

  private func restartAfterOutputChange() {
    guard let current = player, current.isPlaying, let file = current.url else { return }
    let resumeTime = current.currentTime
    current.stop()
    do {
      let replacement = try makePlayer(file: file)
      replacement.currentTime = min(resumeTime, max(0, replacement.duration - 0.05))
      player = replacement
      guard replacement.play() else {
        throw PlaybackError.couldNotStart
      }
      onOutputChanged?(nil)
    } catch {
      player = nil
      onOutputChanged?(error.localizedDescription)
    }
  }
}

private enum PlaybackError: LocalizedError {
  case couldNotPrepare
  case couldNotStart

  var errorDescription: String? {
    switch self {
    case .couldNotPrepare: "The audio system could not prepare this reference."
    case .couldNotStart: "The audio system could not start playback."
    }
  }
}

private final class DefaultOutputMonitor: @unchecked Sendable {
  private let queue = DispatchQueue(label: "com.berndprager.rodd.default-output")
  private var address = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultOutputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  private let listener: AudioObjectPropertyListenerBlock
  private var isRegistered = false

  init(handler: @escaping @Sendable () -> Void) {
    listener = { _, _ in handler() }
    let status = AudioObjectAddPropertyListenerBlock(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      queue,
      listener
    )
    isRegistered = status == noErr
  }

  deinit {
    guard isRegistered else { return }
    AudioObjectRemovePropertyListenerBlock(
      AudioObjectID(kAudioObjectSystemObject),
      &address,
      queue,
      listener
    )
  }
}

@MainActor
final class AppPlaybackAnnouncer: PlaybackAnnouncing {
  func announce(_ message: String) {
    guard let window = NSApp.mainWindow else { return }
    NSAccessibility.post(
      element: window,
      notification: .announcementRequested,
      userInfo: [
        .announcement: message,
        .priority: NSAccessibilityPriorityLevel.medium.rawValue,
      ]
    )
  }
}
