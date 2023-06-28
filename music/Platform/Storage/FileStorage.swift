import Foundation

final class FileStorage {
    
    func getSavedFileURLs() -> [URL] {
        let domainURLs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        
        guard let url = domainURLs.first else {
            return []
        }
        
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: []
        ) else {
            return []
        }
        return fileURLs
    }
    
    func saveDownloadedFile(tempFileURL: URL, name: String) -> URL? {
        let domainURLs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )

        guard let destinationURL = domainURLs.first?.appendingPathComponent(name) else {
            return nil
        }
        
        do {
            try? FileManager.default.removeItem(at: destinationURL)
            try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
            return destinationURL
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
