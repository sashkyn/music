import SwiftUI

@main
struct MusicApp: App {
    
    var body: some Scene {
        WindowGroup {
            TrackListScreen(
                viewModel: .init(
                    service: TrackGoogleDiskService(),
                    fileDownloader: FileManagerDownloader(),
                    fileStorage: DocumentsFileStorage(),
                    player: DevicePlayer()
                )
            )
        }
    }
}
