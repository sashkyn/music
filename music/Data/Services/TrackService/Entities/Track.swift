import Foundation

// to file name
// from file name

struct Track: Decodable {
    let id: RemoteId
    let name: String
    let audioURL: String
}
