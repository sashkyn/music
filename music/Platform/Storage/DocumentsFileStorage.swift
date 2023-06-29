import Foundation

final class DocumentsFileStorage: FileStorage {
    
    private lazy var mainDirectoryURL: URL? = {
        let domainURLs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return domainURLs.first
    }()
    
    func saveFile(
        downloadedFileURL: URL,
        fileName: String,
        format: String
    ) -> URL? {
        guard let fileDestinationURL = mainDirectoryURL?.appendingPathComponent("\(fileName).\(format)") else {
            return nil
        }
        
        do {
            try? FileManager.default.removeItem(at: fileDestinationURL)
            try FileManager.default.moveItem(at: downloadedFileURL, to: fileDestinationURL)
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
}

// MARK: FileStorage + Saved Files

private extension DocumentsFileStorage {
    
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
