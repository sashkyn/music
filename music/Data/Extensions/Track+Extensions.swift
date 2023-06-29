import Foundation

// MARK: Track + safe URL for download

extension Track {

    var audioDownloadURL: URL? {
        URL(string: audioURL)
    }
}
