import SwiftUI

@main
struct MusicApp: App {
    
    var body: some Scene {
        WindowGroup {
            TrackListScreen(
                viewModel: .init(
                    service: TrackGoogleDiskService(),
                    fileDownloader: URLSessionFileDownloader(),
                    fileStorage: DocumentsFileStorage(),
                    player: DevicePlayer()
                )
            )
        }
    }
}
