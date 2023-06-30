import Foundation

struct TrackStoredObject: StoredObject {
    let id: RemoteId
    let name: String
    let audioURL: String
    
    init(
        id: RemoteId,
        name: String,
        audioURL: String
    ) {
        self.id = id
        self.name = name
        self.audioURL = audioURL
    }
}
