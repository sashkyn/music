import Foundation

protocol TrackService {
    func getTracks() async -> Result<[Track], TrackServiceError>
}

enum TrackServiceError: LocalizedError {
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .serverError:
            return "Server error"
        }
    }
}
