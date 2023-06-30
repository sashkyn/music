import Foundation
import AVFoundation

final class TrackListScreenViewModel: ObservableObject {

    var trackViewDataList: [TrackView.ViewData] {
        tracks.map { track in
            TrackView.ViewData(
                trackId: track.id,
                title: track.name,
                buttonState: getActionButtonState(forTrack: track)
            )
        }
    }
    
    @Published var isLoading: Bool = true

    @Published private var tracks: [Track] = []
    @Published private var tracksDownloadingStatuses: [RemoteId: TrackDownloadingStatus] = [:]
    @Published private var playingTrackId: RemoteId? = nil
    @Published private var isPlaying: Bool = false
    
    private let service: TrackService
    private let fileDownloader: FileDownloader
    private let fileStorage: FileStorage
    private let player: DevicePlayer
    private let trackStore: PersistentStore<TrackStoredObject>
    
    init(
        service: TrackService,
        fileDownloader: FileDownloader,
        fileStorage: FileStorage,
        player: DevicePlayer,
        trackStore: PersistentStore<TrackStoredObject>
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
    func loadTracks() {
        Task {
            isLoading = true
            
            try? await trackStore.loadIfNeeded()
            
            let trackStoredObjects = await trackStore.objects
            
            let fileURLs = fileStorage.getSavedFileURLs()
            trackStoredObjects
                .compactMap { object in
                    let fileURL = fileURLs.first(where: { $0.absoluteString.contains(object.metaFile.fullName) })
                    guard let fileURL else {
                        return nil
                    }
                    return (object.id, fileURL)
                }
                .forEach { (trackId, savedFileURL) in
                    tracksDownloadingStatuses[trackId] = .file(url: savedFileURL)
                }
            
            self.tracks = trackStoredObjects.map { $0.toTrack() }
            
            if !self.tracks.isEmpty {
                isLoading = false
            }
            
            let result = await service.getTracks()
            switch result {
            case .success(let tracks):
                self.tracks = tracks

                let trackStoredObjects = tracks.map { TrackStoredObject(fromTrack: $0) }
                try? await trackStore.save(objects: trackStoredObjects)
            case .failure(let error):
                print(error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    @MainActor
    func downloadAudio(forTrackId trackId: RemoteId) {
        guard let track = tracks.first(where: { $0.id == trackId }),
              let url = track.audioDownloadURL else {
            return
        }
        
        fileDownloader.downloadFile(fromURL: url) { [weak self] result in
            switch result {
            case .tempFileURL(let tempFileURL):
                let savedFileURL = self?.fileStorage.save(
                    metaFile: track.metaFile,
                    fromDownloadedFileURL: tempFileURL
                )
                
                guard let savedFileURL else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.tracksDownloadingStatuses[trackId] = .file(url: savedFileURL)
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
        tracks = []
        playingTrackId = nil
        player.stop()
        fileStorage.removeAllFiles()
        tracksDownloadingStatuses = [:]
        
        Task {
            try await trackStore.removeAllObjects()
        }
    }
}

// MARK: TrackListScreenViewModel + Getting TrackActionButton.State for TrackView

private extension TrackListScreenViewModel {
    
    func getActionButtonState(forTrack track: Track) -> TrackActionButton.State {
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
    }
}

private enum TrackDownloadingStatus {
    case readyToDownload
    case downloading(progress: Double)
    case file(url: URL)
}
