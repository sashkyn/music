import SwiftUI

// TODO: show error in alert

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
                                    print("progress")
                                    //viewModel.cancelDownloadTrack(withId: viewData.trackId)
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
            viewModel: .init(
                service: TrackMockService(),
                fileDownloader: SimpleFileDownloader(),
                player: DevicePlayer()
            )
        )
    }
}
