import Foundation

protocol FileDownloader {

    func downloadFile(
        fromURL url: URL,
        savedName: String,
        progress: @escaping (DownloadResult) -> Void
    )
}

enum FileDownloaderError: Error {
    case downloadError
    case movingError
    case destinationNotExist
    case writeError
}

enum DownloadResult {
    case fileURL(URL)
    case progress(Double)
    case error(FileDownloaderError)
}
