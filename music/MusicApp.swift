import SwiftUI

// TODO: handle errors

@main
struct MusicApp: App {

    private var trackStore = PersistentStore<TrackStoredObject>(storeFileName: "TrackData")
    
    var body: some Scene {
        WindowGroup {
            TrackListScreen(
                viewModel: .init(
                    service: TrackGitHubService(),
                    fileDownloader: URLSessionFileDownloader(),
                    fileStorage: DocumentsFileStorage(),
                    player: DevicePlayer(),
                    trackStore: trackStore
                )
            )
                .onAppear {
                    Task {
                        do {
                            try await trackStore.load()
                        } catch {
                            print("TrackStore loadiing error - \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
