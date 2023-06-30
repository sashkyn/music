import AVFoundation

/// TODO:
/// состояние воспроизведения

final class DevicePlayer: Player {
    
    var onStartPlaying: (() -> Void)?
    var onEndPlaying: (() -> Void)?
    
    private let player = AVPlayer()
    
    private var playerStatusObservation: NSKeyValueObservation?
    
    init() {
        self.playerStatusObservation = player.observe(\.rate) { [weak self] (player, _) in
            guard let self else {
                return
            }
            
            if self.player.rate == 0.0 {
                self.onEndPlaying?()
            } else if self.player.rate == 1.0 {
                self.onStartPlaying?()
            }
        }
    }
    
    deinit {
        playerStatusObservation?.invalidate()
    }
    
    func play(fileURL: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: fileURL))
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.replaceCurrentItem(with: nil)
    }
    
    func continuePlaying() {
        guard player.currentItem != nil else {
            return
        }
        
        player.play()
    }
}
