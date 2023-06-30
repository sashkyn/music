import Foundation

// MARK: TrackStoredObject + Init from Track

extension TrackStoredObject {
    
    init(fromTrack track: Track) {
        self.init(
            id: track.id,
            name: track.name,
            audioURL: track.audioURL
        )
    }
}

// MARK: TrackStoredObject + Mapping to Track

extension TrackStoredObject {
    
    func toTrack() -> Track {
        Track(
            id: id,
            name: name,
            audioURL: audioURL
        )
    }
}

// MARK: TrackStoredObject + File name for saving

extension TrackStoredObject {
    
    var metaFile: MetaFile {
        .init(
            name: "\(name.lowercased().replacingOccurrences(of: " ", with: "_"))_\(id)",
            format: .mp3
        )
    }
}
