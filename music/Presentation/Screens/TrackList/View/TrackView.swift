import SwiftUI

struct TrackView: View {
    
    let viewData: ViewData
    let onAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text(viewData.title)
                    .padding(16.0)
                    .foregroundColor(Color.white)
                    .font(.title)
                Spacer()
            }
            Spacer()
                .frame(height: 32.0)
            HStack {
                Spacer()
                TrackActionButton(state: viewData.buttonState)
                    .onTapGesture { onAction() }
                    .frame(width: 24.0, height: 24.0)
                    .padding(16.0)
            }
        }
        .background(Color.gray)
    }
}

extension TrackView {
    
    struct ViewData: Identifiable {
        let id = UUID()
        let trackId: RemoteId
        let title: String
        let buttonState: TrackActionButton.State
    }
}

// MARK: Preview

struct TrackView_Previews: PreviewProvider {
    
    static var previews: some View {
        ScrollView {
            VStack {
                TrackView(
                    viewData: .init(
                        trackId: "1",
                        title: "Song 1",
                        buttonState: .play
                    ),
                    onAction: {}
                )
                    .cornerRadius(16.0)
                    .padding(8.0)
                TrackView(
                    viewData: .init(
                        trackId: "2",
                        title: "Song 1",
                        buttonState: .play
                    ),
                    onAction: {}
                )
                    .cornerRadius(16.0)
                    .padding(8.0)
                TrackView(
                    viewData: .init(
                        trackId: "3",
                        title: "Song 1",
                        buttonState: .play
                    ),
                    onAction: {}
                )
                    .cornerRadius(16.0)
                    .padding(8.0)
                TrackView(
                    viewData: .init(
                        trackId: "4",
                        title: "Song 1",
                        buttonState: .play
                    ),
                    onAction: {}
                )
                    .cornerRadius(16.0)
                    .padding(8.0)
            }
        }
    }
}
