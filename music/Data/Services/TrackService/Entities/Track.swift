import Foundation

struct Track: Hashable, Decodable {
    let id: RemoteId
    let name: String
    let audioURL: String
}
