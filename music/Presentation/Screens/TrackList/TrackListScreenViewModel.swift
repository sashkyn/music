import Foundation
import AVFoundation

// TODO: pull to refresh

final class TrackListScreenViewModel: ObservableObject {

    var trackViewDataList: [TrackView.ViewData] {
        tracks.map { track in
            let buttonState: TrackActionButton.State = {
                if playingTrackId == track.id {
                    if isPlaying {
                        return .pause
                    } else {
                        return .play
                    }
                }
                
                switch tracksDownloadingStatuses[track.id] {
                case .readyToDownload:
                    return .download
                case .downloading(let value):
                    return .progress(value: value)
                case .file:
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
    @Published private var tracksDownloadingStatuses: [RemoteId: TrackDownloadingStatus] = [:]
    @Published private var playingTrackId: RemoteId? = nil
    @Published private var isPlaying: Bool = false
    
    private let service: TrackService
    private let fileDownloader: FileDownloader
    private let fileStorage: FileStorage
    private let player: DevicePlayer
    @Published private var trackStore: Store<TrackStoredObject>
    
    init(
        service: TrackService,
        fileDownloader: FileDownloader,
        fileStorage: FileStorage,
        player: DevicePlayer,
        trackStore: Store<TrackStoredObject>
    ) {
        self.service = service
        self.fileDownloader = fileDownloader
        self.fileStorage = fileStorage
        self.player = player
        self.trackStore = trackStore
        
        self.player.onStartPlaying = { [weak self] in
            self?.isPlaying = true
        }
        
        self.player.onEndPlaying = { [weak self] in
            self?.isPlaying = false
        }
    }
    
    @MainActor
    func getTracks() {
        Task {
            isLoading = true
            
            let trackStoredObjects = await trackStore.objects
            trackStoredObjects
                .filter { $0.downloadedFileURL != nil }
                .forEach {
                    guard let fileURL = $0.downloadedFileURL else {
                        return
                    }
                    
                    guard fileStorage.isExist(fileURL: fileURL) else {
                        return
                    }
                    
                    tracksDownloadingStatuses[$0.id] = .file(url: fileURL)
                }
            
            self.tracks = trackStoredObjects.map { $0.toTrack() }
            
            if !self.tracks.isEmpty {
                isLoading = false
            }
            
            let result = await service.getTracks()
            switch result {
            case .success(let tracks):
                self.tracks = tracks

                let trackStoredObjects = tracks.map { TrackStoredObject.init(fromTrack: $0) }
                try? await trackStore.save(objects: trackStoredObjects)
            case .failure(let error):
                self.error = error
            }
            isLoading = false
        }
    }

    @MainActor
    func downloadTrack(withId trackId: RemoteId) {
        guard let track = tracks.first(where: { $0.id == trackId }),
              let url = track.audioDownloadURL else {
            return
        }
        
        fileDownloader.downloadFile(fromURL: url) { [weak self] result in
            switch result {
            case .tempFileURL(let tempFileURL):
                let savedFileURL = self?.fileStorage.save(
                    metaFile: .init(name: "\(trackId)", format: .mp3),
                    fromDownloadedFileURL: tempFileURL
                )
                
                guard let savedFileURL else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.tracksDownloadingStatuses[trackId] = .file(url: savedFileURL)
                }
                
                Task {
                    // Updating Store
                    let trackStoredObject = TrackStoredObject(fromTrack: track)
                        .withUpdated(downloadedFileURL: savedFileURL)
                    
                    try? await self?.trackStore.update(object: trackStoredObject)
                }
            case .progress(let progressValue):
                DispatchQueue.main.async {
                    self?.tracksDownloadingStatuses[trackId] = .downloading(progress: progressValue)
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    @MainActor
    func playTrack(withId trackId: RemoteId) {
        if playingTrackId == trackId {
            player.continuePlaying()
            return
        }
        
        guard case let .file(url) = tracksDownloadingStatuses[trackId] else {
            return
        }
        
        player.play(fileURL: url)
        
        playingTrackId = trackId
    }
    
    @MainActor
    func pauseTrack() {
        player.pause()
    }
    
    @MainActor
    func clearCache() {
        Task {
            tracks = []
            playingTrackId = nil
            player.stop()
            fileStorage.removeAllFiles()
            tracksDownloadingStatuses = [:]
            try await trackStore.removeAllObjects()
        }
    }
}

private enum TrackDownloadingStatus {
    case readyToDownload
    case downloading(progress: Double)
    case file(url: URL)
}
