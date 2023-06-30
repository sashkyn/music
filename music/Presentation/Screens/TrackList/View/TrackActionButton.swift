import SwiftUI

struct TrackActionButton: View {
    
    let state: State
    
    var body: some View {
        switch state {
        case .play:
            Image("play-icon")
        case .download:
            Image("download-icon")
        case .pause:
            Image("pause-icon")
        case .progress(let value):
            ZStack {
                Circle()
                    .stroke(
                        Color.white,
                        lineWidth: 3.0
                    )
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(
                        Color.red,
                        lineWidth: 3.0
                    )
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 22.0, height: 22.0)
            .padding(2.0)
        }
    }
}

// MARK: State

extension TrackActionButton {
    
    enum State: Hashable {
        case play
        case pause
        case download
        case progress(value: Double)
    }
}

// MARK: Preview

struct TrackActionButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            TrackActionButton(state: .download)
            Spacer().frame(height: 16)
            TrackActionButton(state: .play)
            Spacer().frame(height: 16)
            TrackActionButton(state: .pause)
            Spacer().frame(height: 16)
            TrackActionButton(state: .progress(value: 0.9))
        }
        .padding(16.0)
        .background(Color.gray)
    }
}
