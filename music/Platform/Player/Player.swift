import Foundation

protocol Player {
    func play(fileURL: URL)
    func pause()
    func continuePlaying()
    func stop()
}
