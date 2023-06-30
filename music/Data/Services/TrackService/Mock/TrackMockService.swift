import Foundation

final class TrackMockService: TrackService {
    
    func getTracks() async -> Result<[Track], TrackServiceError> {
        .success([
//            Track(id: "1", name: "Song 1", audioURL: "t.me"),
//            Track(id: "2", name: "Song 1", audioURL: "t.me"),
//            Track(id: "3", name: "Song 1", audioURL: "t.me"),
//            Track(id: "4", name: "Song 1", audioURL: "t.me"),
//            Track(id: "5", name: "Song 1", audioURL: "t.me"),
//            Track(id: "6", name: "Song 1", audioURL: "t.me")
        ])
    }
}
