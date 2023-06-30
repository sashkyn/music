import Foundation

actor PersistentStore<T: StoredObject>: ObservableObject {
    
    @Published
    private(set) var objects: [T] = []
    private(set) var isLoaded: Bool = false
    
    private lazy var storeFileURL: URL? = {
        let url = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        return url?.appendingPathComponent("\(storeFileName).data")
    }()
    
    private let storeFileName: String
    
    init(storeFileName: String) {
        self.storeFileName = storeFileName
    }
    
    func loadIfNeeded() async throws {
        guard !isLoaded else {
            return
        }
        
        guard let storeFileURL else {
            return
        }
        
        let task = Task<[T], Error> {
            guard let data = try? Data(contentsOf: storeFileURL) else {
                return []
            }
            let objects = try JSONDecoder().decode([T].self, from: data)
            return objects
        }
        
        let objects = try await task.value
        self.objects = objects
        self.isLoaded = true
    }
    
    func save(objects: [T]) async throws {
        guard let storeFileURL else {
            return
        }
        
        let task = Task {
            let data = try JSONEncoder().encode(objects)
            try data.write(to: storeFileURL)
        }
        _ = try await task.value
    }
    
    func update(object: T) async throws {
        guard let objectToUpdateIndex = objects.firstIndex(where: { $0.id == object.id }) else {
            return
        }
        
        objects[objectToUpdateIndex] = object
        try await save(objects: objects)
    }
    
    func removeAllObjects() async throws {
        try await save(objects: [])
    }
}
