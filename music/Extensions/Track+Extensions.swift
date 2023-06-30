import Foundation

// MARK: Track + Safety URL for download

extension Track {

    var audioDownloadURL: URL? {
        URL(string: audioURL)
    }
}
