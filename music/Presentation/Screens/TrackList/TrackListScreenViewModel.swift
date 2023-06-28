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
                
                switch tracksStatuses[track.id] {
                case .readyToDownload:
                    return .download
                case .downloading(let value):
                    return .progress(value: value)
                case .fileURL:
                    return .play
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
    @Published private var tracksStatuses: [RemoteId: TrackDownloadingStatus] = [:]
    @Published private var activeTrackId: RemoteId? = nil
    @Published private var isPlaying: Bool = false
    
    private let service: TrackService
    private let fileDownloader: FileDownloader
    private let fileStorage: FileStorage
    private let player: DevicePlayer
    
    init(
        service: TrackService,
        fileDownloader: FileDownloader,
        fileStorage: FileStorage,
        player: DevicePlayer
    ) {
        self.service = service
        self.fileDownloader = fileDownloader
        self.fileStorage = fileStorage
        self.player = player
    }
    
    @MainActor
    func getTracks() async {
        let result = await service.getTracks()
        switch result {
        case .success(let tracks):
            self.tracks = tracks
        case .failure(let error):
            self.error = error
        }
        isLoading = false
    }
    
    @MainActor
    func downloadTrack(withId trackId: RemoteId) {
        guard let url = tracks.first(where: { $0.id == trackId })?.audioURL else {
            return
        }
        
        fileDownloader.downloadFile(fromURL: url) { [weak self] result in
            switch result {
            case .tempFileURL(let tempFileURL):
                guard let savedFileURL = self?.fileStorage.saveDownloadedFile(
                    tempFileURL: tempFileURL,
                    name: "\(trackId).mp3"
                ) else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.tracksStatuses[trackId] = .fileURL(url: savedFileURL)
                }
            case .progress(let progressValue):
                DispatchQueue.main.async {
                    self?.tracksStatuses[trackId] = .downloading(progress: progressValue)
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    @MainActor
    func playTrack(withId trackId: RemoteId) {
        if activeTrackId == trackId {
            player.continuePlaying()
            isPlaying = true
            return
        }
        
        guard case let .fileURL(url) = tracksStatuses[trackId] else {
            return
        }

        player.play(fileURL: url)
        
        activeTrackId = trackId
        isPlaying = true
    }
    
    @MainActor
    func pauseTrack() {
        player.pause()
        
        isPlaying = false
    }
    
    @MainActor
    func clearCache() {
        fileStorage.clear()
        tracksStatuses = [:]
    }
}

private enum TrackDownloadingStatus {
    case readyToDownload
    case downloading(progress: Double)
    case fileURL(url: URL)
}
