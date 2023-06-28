import Foundation

// TODO: make audioURL safety
// to file name
// from file name

typealias RemoteId = String

struct Track: Decodable {
    let id: RemoteId
    let name: String
    let audioURL: URL
}
