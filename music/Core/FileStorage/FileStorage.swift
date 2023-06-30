import Foundation

protocol FileStorage {
    func save(metaFile: MetaFile, fromDownloadedFileURL: URL) -> URL?
    func removeAllFiles()
    func isExist(fileURL: URL) -> Bool
    func getSavedFileURLs() -> [URL]
}
