import Foundation

protocol FileStorage {
    
    func saveFile(downloadedFileURL: URL, fileName: String, format: String) -> URL?
    func removeAllFiles()
}
