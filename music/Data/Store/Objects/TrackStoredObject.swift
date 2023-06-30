import Foundation

struct TrackStoredObject: StoredObject {
    let id: RemoteId
    let name: String
    let audioURL: String
    let downloadedFileURL: URL?
    
    init(
        id: RemoteId,
        name: String,
        audioURL: String,
        downloadedFileURL: URL?
    ) {
        self.id = id
        self.name = name
        self.audioURL = audioURL
        self.downloadedFileURL = downloadedFileURL
    }
}
