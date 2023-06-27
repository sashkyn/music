import Foundation

/// TODO: обработать ошибку мувинга, когда файл уже существует

final class SimpleFileDownloader: FileDownloader {
    
    func downloadFile(
        fromURL url: URL,
        savedName: String,
        progress: @escaping (DownloadResult) -> Void
    ) {
        progress(.progress(0.01))
        let request = URLRequest(url: url)
        
        var observation: NSKeyValueObservation?
        
        let downloadTask = URLSession.shared.downloadTask(with: request) { tempFileURL, _, error in
            defer {
                observation?.invalidate()
            }
            
            guard let tempFileURL else {
                progress(.error(.downloadError))
                return
            }
            
            let domainURLs = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            )
    
            // Moving start
            guard let destinationURL = domainURLs.first?.appendingPathComponent(savedName) else {
                progress(.error(.destinationNotExist))
                return
            }
            
            do {
                try FileManager.default.removeItem(at: destinationURL)
                try FileManager.default.moveItem(at: tempFileURL, to: destinationURL)
            } catch {
                progress(.error(.movingError))
                return
            }
            // Moving end
            
            progress(.fileURL(destinationURL))
        }
        
        observation = downloadTask.progress.observe(\.fractionCompleted) { value, _ in
            progress(.progress(value.fractionCompleted))
        }
        
        downloadTask.resume()
    }
}
