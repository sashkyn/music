import Foundation

protocol FileDownloader {

    func downloadFile(
        fromURL url: URL,
        progress: @escaping (DownloadResult) -> Void
    )
}

enum FileDownloaderError: Error {
    case downloadError
}

enum DownloadResult {
    case tempFileURL(URL)
    case progress(Double)
    case error(FileDownloaderError)
}
