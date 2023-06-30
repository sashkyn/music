import Foundation

// MARK: TrackStoredObject + Init from Track

extension TrackStoredObject {
    
    init(fromTrack track: Track) {
        self.init(
            id: track.id,
            name: track.name,
            audioURL: track.audioURL,
            downloadedFileURL: nil
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

// MARK: TrackStoredObject + Pretty mutating

extension TrackStoredObject {
    
    func withUpdated(
        id: RemoteId? = nil,
        name: String? = nil,
        audioURL: String? = nil,
        downloadedFileURL: URL? = nil
    ) -> Self {
        .init(
            id: id ?? self.id,
            name: name ?? self.name,
            audioURL: audioURL ?? self.audioURL,
            downloadedFileURL: downloadedFileURL ?? self.downloadedFileURL
        )
    }
}
