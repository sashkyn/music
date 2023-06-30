import SwiftUI

@main
struct MusicApp: App {
    
    var body: some Scene {
        WindowGroup {
            TrackListScreen(
                viewModel: .init(
                    service: TrackGitHubService(),
                    fileDownloader: URLSessionFileDownloader(),
                    fileStorage: DocumentsFileStorage(),
                    player: DevicePlayer(),
                    trackStore: PersistentStore<TrackStoredObject>(storeFileName: "TrackData")
                )
            )
        }
    }
}
