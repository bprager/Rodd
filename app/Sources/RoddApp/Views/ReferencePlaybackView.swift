import SwiftUI

struct ReferencePlaybackView: View {
  let pack: PrayerPack
  let line: PrayerLine
  @ObservedObject var controller: ReferencePlaybackController

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack(alignment: .firstTextBaseline) {
        Text("Reference playback")
          .font(.headline)
          .accessibilityAddTraits(.isHeader)
        Spacer()
        Picker("Tempo", selection: tempoBinding) {
          ForEach(ReferenceTempoOption.allCases) { tempo in
            Text(pack.referenceAudio.tempos[tempo.rawValue]?.label ?? tempo.rawValue.capitalized)
              .tag(tempo)
          }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(maxWidth: 260)
        .accessibilityLabel("Tempo")
        .accessibilityHint("Changes between recorded natural and slower teaching tempo")
      }

      ForEach(ReferenceVoice.allCases) { voice in
        if let style = pack.referenceAudio.styles[voice.rawValue] {
          playbackRow(voice: voice, style: style)
        }
      }

      playbackStatus
    }
    .roddPanel()
    .foregroundStyle(RoddTheme.ink)
  }

  private var tempoBinding: Binding<ReferenceTempoOption> {
    Binding(
      get: { controller.selectedTempo },
      set: { controller.changeTempo(to: $0, for: line, in: pack) }
    )
  }

  @ViewBuilder
  private func playbackRow(voice: ReferenceVoice, style: ReferenceStyle) -> some View {
    let track = pack.referenceTrack(
      lineID: line.id,
      voice: voice,
      tempo: controller.selectedTempo
    )
    let active = track.map(controller.isPlaying) ?? false

    HStack(alignment: .top, spacing: 18) {
      VStack(alignment: .leading, spacing: 5) {
        Text(style.label)
          .font(.subheadline.weight(.semibold))
        Text(style.purpose)
          .fixedSize(horizontal: false, vertical: true)
        Text(style.limitation)
          .font(.callout)
          .foregroundStyle(RoddTheme.muted)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        guard let track,
          let tempo = pack.referenceAudio.tempos[controller.selectedTempo.rawValue]
        else { return }
        controller.toggle(track, styleLabel: style.label, tempoLabel: tempo.label)
      } label: {
        Label(
          active ? "Stop" : "Play",
          systemImage: active ? "stop.fill" : "play.fill"
        )
        .frame(minWidth: 74)
      }
      .buttonStyle(.bordered)
      .tint(active ? RoddTheme.amber : RoddTheme.lichen)
      .controlSize(.large)
      .disabled(track == nil)
      .accessibilityLabel("\(active ? "Stop" : "Play") \(style.label)")
      .accessibilityHint(
        active
          ? "Stops the current reference"
          : "Stops any other reference and plays this one at \(tempoLabel)"
      )
    }
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private var playbackStatus: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        Image(systemName: controller.isPlaying ? "speaker.wave.2.fill" : "speaker")
          .foregroundStyle(controller.isPlaying ? RoddTheme.lichen : RoddTheme.muted)
          .accessibilityHidden(true)
        Text(controller.statusMessage)
          .font(.callout.weight(.medium))
          .fixedSize(horizontal: false, vertical: true)
      }

      if controller.isPlaying, controller.duration > 0 {
        ProgressView(value: controller.elapsed, total: controller.duration)
          .accessibilityLabel("Reference playback progress")
          .accessibilityValue(
            "\(formatted(controller.elapsed)) of \(formatted(controller.duration))"
          )
      }
    }
    .accessibilityElement(children: .contain)
  }

  private var tempoLabel: String {
    pack.referenceAudio.tempos[controller.selectedTempo.rawValue]?.label
      ?? controller.selectedTempo.rawValue.capitalized
  }

  private func formatted(_ seconds: TimeInterval) -> String {
    let rounded = max(0, Int(seconds.rounded()))
    return "\(rounded / 60):\(String(format: "%02d", rounded % 60))"
  }
}
