import Foundation

final class FileStorage {
    
    private lazy var mainDirectoryURL: URL? = {
        let domainURLs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return domainURLs.first
    }()
    
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
    
    func clear() {
        let fileURLs = getSavedFileURLs()
        fileURLs.forEach {
            try? FileManager.default.removeItem(at: $0)
        }
    }
}
