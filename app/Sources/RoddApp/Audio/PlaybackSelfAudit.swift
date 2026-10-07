#if DEBUG
  import AppKit
  import Foundation

  @MainActor
  enum PlaybackSelfAudit {
    static func runIfRequested(pack: PrayerPack?) async {
      guard ProcessInfo.processInfo.arguments.contains("--playback-audit") else { return }
      guard let pack, let line = pack.orderedLines.first else {
        fail("the bundled prayer pack was unavailable")
      }
      guard
        let precise = pack.referenceTrack(lineID: line.id, voice: .precise, tempo: .natural),
        let naturalized = pack.referenceTrack(
          lineID: line.id,
          voice: .naturalized,
          tempo: .natural
        ),
        let preciseStyle = pack.referenceAudio.styles[ReferenceVoice.precise.rawValue],
        let naturalizedStyle = pack.referenceAudio.styles[ReferenceVoice.naturalized.rawValue],
        let naturalTempo = pack.referenceAudio.tempos[ReferenceTempoOption.natural.rawValue]
      else {
        fail("line 1 reference metadata was incomplete")
      }

      let engine = AVAudioFilePlaybackEngine(volume: 0)
      let controller = ReferencePlaybackController(
        engine: engine,
        announcer: SilentPlaybackAnnouncer()
      )

      controller.play(
        precise,
        styleLabel: preciseStyle.label,
        tempoLabel: naturalTempo.label
      )
      try? await Task.sleep(for: .milliseconds(150))
      guard controller.isPlaying(precise), controller.elapsed >= 0 else {
        fail("the precise reference did not start")
      }

      controller.play(
        naturalized,
        styleLabel: naturalizedStyle.label,
        tempoLabel: naturalTempo.label
      )
      try? await Task.sleep(for: .milliseconds(100))
      guard controller.isPlaying(naturalized), !controller.isPlaying(precise) else {
        fail("switching references did not remain exclusive")
      }

      engine.simulateOutputChangeForVerification()
      try? await Task.sleep(for: .milliseconds(100))
      guard controller.isPlaying(naturalized),
        controller.statusMessage.contains("new output")
      else {
        fail("playback did not recover from an output change")
      }

      controller.changeTempo(to: .teaching, for: line, in: pack)
      try? await Task.sleep(for: .milliseconds(100))
      guard controller.activeTrack?.tempo == .teaching, controller.isPlaying else {
        fail("the teaching-tempo file did not replace the natural-speed file")
      }

      controller.stop()
      guard !controller.isPlaying else {
        fail("playback did not stop")
      }

      print("PLAYBACK AUDIT PASSED: exclusive, offline, tempo switch, output recovery")
      NSApplication.shared.terminate(nil)
    }

    private static func fail(_ message: String) -> Never {
      print("PLAYBACK AUDIT FAILED: \(message)")
      exit(1)
    }
  }

  @MainActor
  private final class SilentPlaybackAnnouncer: PlaybackAnnouncing {
    func announce(_: String) {}
  }
#endif
