import Foundation

// MARK: Track + safe URL for download

extension Track {
    
    var downloadURL: URL? {
        URL(string: audioURL)
    }
}
