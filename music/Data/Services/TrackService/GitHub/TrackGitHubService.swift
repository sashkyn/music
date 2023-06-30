import Foundation

final class TrackGitHubService: TrackService {
    
    func getTracks() async -> Result<[Track], TrackServiceError> {
            do {
                let (data, _) = try await URLSession.shared.data(from: Constants.trackListURL)
                let trackList = try JSONDecoder().decode(TrackList.self, from: data)
                let tracks = trackList.data
                return .success(tracks)
            } catch {
                return .failure(.serverError)
            }
        }
}

private struct Constants {
    
    static let trackListURL = URL(
        string: "https://gist.githubusercontent.com/Lenhador/a0cf9ef19cd816332435316a2369bc00/raw/a1338834fc60f7513402a569af09ffa302a26b63/Songs.json"
    )!
}
