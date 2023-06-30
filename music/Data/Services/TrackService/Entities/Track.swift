import Foundation

struct Track: Decodable {
    let id: RemoteId
    let name: String
    let audioURL: String
}
