import AppKit
import Combine
import Foundation

@MainActor
final class SoundController {
    private var stateCancellable: AnyCancellable?
    private var nowPlayingCancellable: AnyCancellable?
    private var lastSource: SoundSource = .none

    func start(with state: AtmosphereState) {
        stateCancellable = Publishers.CombineLatest4(
            state.$isEnabled,
            state.$soundEnabled,
            state.$selectedMode,
            state.$customPlaylistURL
        )
        .sink { [weak self] _, _, _, _ in
            self?.syncPlayback(for: state)
        }

        nowPlayingCancellable = Timer.publish(every: 2.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshNowPlaying(for: state)
            }

        syncPlayback(for: state)
        refreshNowPlaying(for: state)
    }

    private func syncPlayback(for state: AtmosphereState) {
        let source = state.activeSoundSource
        guard source != lastSource else {
            refreshNowPlaying(for: state)
            return
        }

        lastSource = source

        switch source {
        case .none:
            pauseSpotify()
            if state.selectedMode == .focused {
                state.setNowPlayingText("Focused mode: no music")
            } else if !state.soundEnabled || !state.isEnabled {
                state.setNowPlayingText("Sound off")
            } else if state.selectedMode == .custom {
                state.setNowPlayingText("Add a Spotify playlist URL")
            } else {
                state.setNowPlayingText("Not Playing")
            }
        case .playlist(let url):
            playPlaylist(urlString: url)
            state.setNowPlayingText("Loading...")
        }
    }

    private func refreshNowPlaying(for state: AtmosphereState) {
        if case .none = state.activeSoundSource {
            return
        }

        guard let text = currentTrackText(), !text.isEmpty else {
            return
        }
        state.setNowPlayingText(text)
    }

    private func playPlaylist(urlString: String) {
        let input = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }

        let playlistURI = spotifyPlaylistURI(from: input)
        let didOpenSpotifyURI: Bool
        if let playlistURI, let uriURL = URL(string: playlistURI) {
            didOpenSpotifyURI = NSWorkspace.shared.open(uriURL)
        } else {
            didOpenSpotifyURI = false
        }

        // If direct Spotify URI open fails, fall back to opening the provided URL.
        if !didOpenSpotifyURI, let url = URL(string: input) {
            _ = NSWorkspace.shared.open(url)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if let playlistURI {
                _ = self.executeAppleScript(
                    """
                    tell application "Spotify"
                        activate
                        try
                            play track "\(playlistURI)"
                        on error
                            play
                        end try
                    end tell
                    """
                )
            } else {
                _ = self.executeAppleScript(
                    """
                    tell application "Spotify"
                        activate
                        play
                    end tell
                    """
                )
            }
        }
    }

    private func pauseSpotify() {
        _ = executeAppleScript(
            """
            tell application "Spotify"
                pause
            end tell
            """
        )
    }

    private func currentTrackText() -> String? {
        let result = executeAppleScript(
            """
            try
                tell application "Spotify"
                    if player state is playing then
                        return name of current track & " - " & artist of current track
                    end if
                    if player state is paused then
                        return "Paused"
                    end if
                end tell
            on error
                return ""
            end try
            """
        )
        return result?.stringValue
    }

    private func spotifyPlaylistURI(from text: String) -> String? {
        if text.hasPrefix("spotify:playlist:") {
            return text
        }

        guard let url = URL(string: text) else { return nil }
        guard url.host?.contains("spotify.com") == true else { return nil }

        let pathComponents = url.pathComponents
        guard let playlistIndex = pathComponents.firstIndex(of: "playlist"),
              pathComponents.count > playlistIndex + 1 else {
            return nil
        }

        let rawPlaylistID = pathComponents[playlistIndex + 1]
        let playlistID = rawPlaylistID.split(separator: "?").first.map(String.init) ?? rawPlaylistID
        guard !playlistID.isEmpty else { return nil }
        return "spotify:playlist:\(playlistID)"
    }

    private func executeAppleScript(_ source: String) -> NSAppleEventDescriptor? {
        guard let script = NSAppleScript(source: source) else { return nil }
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        if error != nil {
            return nil
        }
        return result
    }
}
