import SwiftUI

struct TrackListScreen: View {
    
    @ObservedObject
    var viewModel: TrackListScreenViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView()
                    .onAppear { viewModel.loadTracks() }
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.trackViewDataList, id: \.hashValue) { viewData in
                            TrackView(
                                viewData: viewData,
                                onAction: {
                                    switch viewData.buttonState {
                                    case .download:
                                        viewModel.downloadAudio(forTrackId: viewData.trackId)
                                    case .pause:
                                        viewModel.pauseTrack()
                                    case .play:
                                        viewModel.playTrack(withId: viewData.trackId)
                                    case .progress:
                                        return
                                    }
                                }
                            )
                            .cornerRadius(16.0)
                            .padding(.vertical, 4.0)
                            .padding(.horizontal, 16.0)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .toolbar(
                    content: {
                        ToolbarItem(placement: .principal) {
                            Text("Tracklist").font(.body.bold())
                        }
                    })
                .navigationBarItems(
                    leading: Button(
                        action: {
                            viewModel.loadTracks()
                        },
                        label: {
                            Text("Update")
                        }
                    ),
                    trailing: Button(
                        action: {
                            viewModel.clearCache()
                        },
                        label: {
                            Text("Clear cache")
                        }
                    )
                )
            }
        }
    }
}

// MARK: Preview

struct TrackListScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        TrackListScreen(
            viewModel: .init(
                service: TrackGitHubService(),
                fileDownloader: URLSessionFileDownloader(),
                fileStorage: DocumentsFileStorage(),
                player: DevicePlayer(),
                trackStore: PersistentStore(storeFileName: "mock")
            )
        )
    }
}
