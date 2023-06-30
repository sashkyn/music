import Foundation

protocol FileStorage {
    func save(metaFile: MetaFile, fromDownloadedFileURL: URL) -> URL?
    func removeAllFiles()
    func getSavedFileURLs() -> [URL]
}
