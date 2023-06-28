import AVFoundation

/// TODO:
/// protocol
/// коллбек на конец трека
/// состояние воспроизведения
/// исправить баг с мейн очередью

final class DevicePlayer {
    private let player = AVPlayer()
    
    func play(fileURL: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: fileURL))
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func continuePlaying() {
        guard player.currentItem != nil else {
            return
        }
        
        player.play()
    }
}