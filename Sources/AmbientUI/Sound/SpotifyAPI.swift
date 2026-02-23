import Foundation

enum SpotifyWebAPI {
    enum EmbedResource {
        case playlist(String)
        case album(String)
    }

    static func embedResource(from input: String) -> EmbedResource? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if trimmed.hasPrefix("spotify:playlist:") {
            let id = String(trimmed.dropFirst("spotify:playlist:".count))
            return id.isEmpty ? nil : .playlist(id)
        }

        if trimmed.hasPrefix("spotify:album:") {
            let id = String(trimmed.dropFirst("spotify:album:".count))
            return id.isEmpty ? nil : .album(id)
        }

        guard let url = URL(string: trimmed) else { return nil }
        guard url.host?.contains("spotify.com") == true else { return nil }

        let components = url.pathComponents
        if let playlistIndex = components.firstIndex(of: "playlist"),
           components.count > playlistIndex + 1 {
            let id = components[playlistIndex + 1]
            return id.isEmpty ? nil : .playlist(id)
        }

        if let albumIndex = components.firstIndex(of: "album"),
           components.count > albumIndex + 1 {
            let id = components[albumIndex + 1]
            return id.isEmpty ? nil : .album(id)
        }

        return nil
    }

    static func embedURL(for resource: EmbedResource) -> URL? {
        switch resource {
        case .playlist(let id):
            return URL(string: "https://open.spotify.com/embed/playlist/\(id)?utm_source=generator")
        case .album(let id):
            return URL(string: "https://open.spotify.com/embed/album/\(id)?utm_source=generator")
        }
    }
}
