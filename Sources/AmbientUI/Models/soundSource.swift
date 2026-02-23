import Foundation

struct SoundTrack: Equatable {
    var title: String
    var source: SoundTrackSource
}

enum SoundTrackSource: Equatable {
    case bundled(name: String, ext: String, subdirectory: String)
    case remote(urlString: String)
}

struct SoundPlaylist: Equatable {
    var id: String
    var title: String
    var tracks: [SoundTrack]
}

enum SoundSource: Equatable {
    case none
    case playlist(SoundPlaylist)
}
