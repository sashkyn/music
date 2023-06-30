import Foundation

struct MetaFile {
    let name: String
    let format: FileFormat
    
    var fullName: String {
        "\(name).\(format.rawValue)"
    }
    
    init(name: String, format: FileFormat) {
        self.name = name
        self.format = format
    }
}

enum FileFormat: String {
    case mp3 = "mp3"
    case data = "data"
}
