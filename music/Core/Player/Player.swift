import Foundation

protocol Player {
    var onStartPlaying: (() -> Void)? { get set }
    var onEndPlaying: (() -> Void)? { get set }
    
    func play(fileURL: URL)
    func pause()
    func continuePlaying()
    func stop()
}
