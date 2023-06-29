import Foundation

final class SimpleFileDownloader: FileDownloader {
    
    func downloadFile(
        fromURL url: URL,
        progress: @escaping (DownloadResult) -> Void
    ) {
        progress(.progress(0.01))
        let request = URLRequest(url: url)
        
        var observation: NSKeyValueObservation?
        
        let downloadTask = URLSession.shared.downloadTask(with: request) { tempFileURL, _, _ in
            defer {
                observation?.invalidate()
            }
            
            guard let tempFileURL else {
                progress(.error(.downloadError))
                return
            }
            
            progress(.tempFileURL(tempFileURL))
        }
        
        observation = downloadTask.progress.observe(\.fractionCompleted) { value, _ in
            progress(.progress(value.fractionCompleted))
        }
        
        downloadTask.resume()
    }
}
