import SwiftUI

// TODO: show error in alert

final class TrackListScreenViewModel: ObservableObject {
    
    @Published private var tracks: [Track] = []
    
    var trackViewDataList: [TrackView.ViewData] {
        tracks.map {
            .init(
                trackId: $0.id,
                title: $0.name,
                buttonState: .download
            )
        }
    }
    
    @Published var isLoading: Bool = true
    @Published var error: TrackServiceError? = nil
    
    private let service: TrackService
    
    init(service: TrackService) {
        self.service = service
    }
    
    @MainActor
    func getTracks() async {
        defer { isLoading = false }
        
        let result = await service.getTracks()
        switch result {
        case .success(let tracks):
            self.tracks = tracks
        case .failure(let error):
            self.error = error
        }
    }
    
    @MainActor
    func downloadTrack(withId: RemoteId) {
        // TODO: Implement
    }
    
    @MainActor
    func playTrack(withId: RemoteId) {
        // TODO: Implement
    }
    
    @MainActor
    func pauseTrack(withId: RemoteId) {
        // TODO: Implement
    }
    
    @MainActor
    func cancelDownloadTrack(withId: RemoteId) {
        // TODO: Implement
    }
}

struct TrackListScreen: View {
    
    @StateObject
    var viewModel: TrackListScreenViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .onAppear { Task { await viewModel.getTracks() } }
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.trackViewDataList) { viewData in
                        TrackView(
                            viewData: viewData,
                            onAction: {
                                switch viewData.buttonState {
                                case .download:
                                    viewModel.downloadTrack(withId: viewData.trackId)
                                case .pause:
                                    viewModel.pauseTrack(withId: viewData.trackId)
                                case .play:
                                    viewModel.playTrack(withId: viewData.trackId)
                                case .progress:
                                    viewModel.cancelDownloadTrack(withId: viewData.trackId)
                                }
                            }
                        )
                            .cornerRadius(16.0)
                            .padding(.vertical, 4.0)
                            .padding(.horizontal, 16.0)
                    }
                }
            }
        }
    }
}

// MARK: Preview

struct TrackListScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        TrackListScreen(
            viewModel: .init(service: TrackMockService())
        )
    }
}
