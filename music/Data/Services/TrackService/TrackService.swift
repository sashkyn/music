import Foundation

protocol TrackService {
    func getTracks() async -> Result<[Track], TrackServiceError>
}

enum TrackServiceError: Error {
    case serverError
}
