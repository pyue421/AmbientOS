import AVFoundation
import Combine
import Foundation

@MainActor
final class SoundController {
    private var stateCancellable: AnyCancellable?
    private var lastSource: SoundSource = .none
    private let player = AVQueuePlayer()
    private var didSetupEndObserver = false
    private var activePlaylist: SoundPlaylist?
    private var activeURLs: [URL] = []

    func start(with state: AtmosphereState) {
        stateCancellable = Publishers.CombineLatest4(
            state.$isEnabled,
            state.$soundEnabled,
            state.$selectedMode,
            state.$customPlaylistURL
        )
        .sink { [weak self] isEnabled, soundEnabled, selectedMode, _ in
            self?.syncPlayback(
                source: self?.sourceFor(
                    isEnabled: isEnabled,
                    soundEnabled: soundEnabled,
                    selectedMode: selectedMode
                ) ?? .none
            )
        }

        installEndObserverIfNeeded()
        player.actionAtItemEnd = .advance
        player.automaticallyWaitsToMinimizeStalling = false
        syncPlayback(
            source: sourceFor(
                isEnabled: state.isEnabled,
                soundEnabled: state.soundEnabled,
                selectedMode: state.selectedMode
            )
        )
    }

    private func syncPlayback(source: SoundSource) {
        if case .none = source {
            pausePlayback()
            lastSource = .none
            return
        }

        guard source != lastSource else {
            if let playlist = activePlaylist {
                startPlayback(for: playlist)
            }
            return
        }

        lastSource = source

        switch source {
        case .none:
            pausePlayback()
        case .playlist(let playlist):
            startPlayback(for: playlist)
        }
    }

    private func sourceFor(isEnabled: Bool, soundEnabled: Bool, selectedMode: AmbientMode) -> SoundSource {
        guard isEnabled, soundEnabled else { return .none }
        guard selectedMode != .custom else { return .none }
        return ModePresets.preset(for: selectedMode).sound
    }

    private func startPlayback(for playlist: SoundPlaylist) {
        guard playlist != activePlaylist else {
            if !player.items().isEmpty, player.rate == 0 {
                player.playImmediately(atRate: 1.0)
            }
            return
        }

        let urls = playlist.tracks.compactMap(resolveURL(for:))
        guard !urls.isEmpty else {
            stopPlayback()
            return
        }

        activePlaylist = playlist
        activeURLs = urls
        player.removeAllItems()
        enqueueAllTracks()
        player.playImmediately(atRate: 1.0)
    }

    private func pausePlayback() {
        player.pause()
    }

    private func stopPlayback() {
        player.pause()
        player.removeAllItems()
        activePlaylist = nil
        activeURLs = []
    }

    private func enqueueAllTracks() {
        for url in activeURLs {
            let item = AVPlayerItem(url: url)
            player.insert(item, after: nil)
        }
    }

    private func installEndObserverIfNeeded() {
        guard !didSetupEndObserver else { return }
        didSetupEndObserver = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackDidEnd(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    @objc
    private func handleTrackDidEnd(_ note: Notification) {
        guard activePlaylist != nil else { return }
        guard let finishedItem = note.object as? AVPlayerItem else { return }
        guard activeURLs.count > 0 else { return }

        // Keep looping by appending another item that matches the one that just finished.
        if let asset = finishedItem.asset as? AVURLAsset {
            let url = asset.url
            if activeURLs.contains(url) {
                player.insert(AVPlayerItem(url: url), after: nil)
            }
        }

        if player.rate == 0 {
            player.play()
        }
    }

    private func resolveURL(for track: SoundTrack) -> URL? {
        switch track.source {
        case let .bundled(name, ext, subdirectory):
            if let direct = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: subdirectory) {
                return direct
            }

            if let root = Bundle.module.url(forResource: name, withExtension: ext) {
                return root
            }

            if let nested = Bundle.module.url(
                forResource: name,
                withExtension: ext,
                subdirectory: "Resources/\(subdirectory)"
            ) {
                return nested
            }

            let targetFile = "\(name).\(ext)"
            let bundleRoot = Bundle.module.bundleURL
            let candidates = [
                bundleRoot.appendingPathComponent(targetFile),
                bundleRoot.appendingPathComponent(subdirectory).appendingPathComponent(targetFile),
                bundleRoot.appendingPathComponent("Resources").appendingPathComponent(subdirectory).appendingPathComponent(targetFile),
            ]
            for candidate in candidates where FileManager.default.fileExists(atPath: candidate.path) {
                return candidate
            }
            return nil
        case let .remote(urlString):
            guard let url = URL(string: urlString) else {
                return nil
            }
            return url
        }
    }
}
