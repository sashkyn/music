import Foundation

// MARK: Track + Safety URL for download

extension Track {

    var audioDownloadURL: URL? {
        URL(string: audioURL)
    }
}

// MARK: Track + File name for saving

extension Track {
    
    var metaFile: MetaFile {
        .init(
            name: "\(name.lowercased().replacingOccurrences(of: " ", with: "_"))_\(id)",
            format: .mp3
        )
    }
}
