import Foundation
import AVFoundation

// TODO: переименовать withId

final class TrackListScreenViewModel: ObservableObject {

    var trackViewDataList: [TrackView.ViewData] {
        tracks.map { track in
            let buttonState: TrackActionButton.State = {
                if activeTrackId == track.id {
                    if isPlaying {
                        return .pause
                    } else {
                        return .play
                    }
                }
                
                switch statuses[track.id] {
                case .fileURL:
                    return .play
                case .progress(let value):
                    return .progress(value: value)
                default:
                    return .download
                }
            }()
            
            return .init(
                trackId: track.id,
                title: track.name,
                buttonState: buttonState
            )
        }
    }
    
    @Published var isLoading: Bool = true
    @Published var error: Error? = nil

    @Published private var tracks: [Track] = []
    @Published private var statuses: [RemoteId: DownloadResult] = [:]
    @Published private var activeTrackId: RemoteId? = nil
    @Published private var isPlaying: Bool = false
    
    private let service: TrackService
    private let fileDownloader: FileDownloader
    private let player: DevicePlayer
    
    init(
        service: TrackService,
        fileDownloader: FileDownloader,
        player: DevicePlayer
    ) {
        self.service = service
        self.fileDownloader = fileDownloader
        self.player = player
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
        guard let url = tracks.first(where: { $0.id == withId })?.audioURL else {
            return
        }
        
        fileDownloader.downloadFile(fromURL: url, savedName: "\(withId).mp3") { [weak self] result in
            DispatchQueue.main.async {
                self?.statuses[withId] = result
            }
        }
    }
    
    @MainActor
    func playTrack(withId: RemoteId) {
        if activeTrackId == withId {
            player.continuePlaying()
            isPlaying = true
            return
        }
        
        guard case let .fileURL(url) = statuses[withId] else {
            return
        }

        player.play(fileURL: url)
        
        activeTrackId = withId
        isPlaying = true
    }
    
    @MainActor
    func pauseTrack(withId: RemoteId) {
        player.pause()
        
        isPlaying = false
    }
}
