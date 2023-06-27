import Foundation

// TODO: make audioURL safety

typealias RemoteId = String

struct Track: Decodable {
    let id: RemoteId
    let name: String
    let audioURL: URL
}
