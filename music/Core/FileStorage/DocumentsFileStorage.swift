import Foundation

final class DocumentsFileStorage: FileStorage {
    
    private lazy var mainDirectoryURL: URL? = {
        let domainURLs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return domainURLs.first
    }()
    
    func save(metaFile: MetaFile, fromDownloadedFileURL: URL) -> URL? {
        guard let fileDestinationURL = mainDirectoryURL?.appendingPathComponent(metaFile.fullName) else {
            return nil
        }
        
        do {
            try? FileManager.default.removeItem(at: fileDestinationURL)
            try FileManager.default.moveItem(at: fromDownloadedFileURL, to: fileDestinationURL)
            return fileDestinationURL
        } catch {
            return nil
        }
    }
    
    func removeAllFiles() {
        let fileURLs = getSavedFileURLs()
        fileURLs.forEach {
            try? FileManager.default.removeItem(at: $0)
        }
    }

    func isExist(fileURL: URL) -> Bool {
        let savedURLs = getSavedFileURLs()
        return savedURLs.contains { url in fileURL == url }
    }
    
    func getSavedFileURLs() -> [URL] {
        guard let mainDirectoryURL else {
            return []
        }
        
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: mainDirectoryURL,
            includingPropertiesForKeys: []
        ) else {
            return []
        }
        return fileURLs
    }
}
