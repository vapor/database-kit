/// Stores key-value pair in a dictionary thread-safely
public final class MemoryKeyedCache: KeyedCache {
    /// The underlying storage of this cache
    private var storage = [String: Any]()

    /// The event loop to put futures on
    private let eventLoop: EventLoop

    /// Sync access
    private let lock: DispatchQueue

    private let memory: DictionaryKeyedCache

    /// The cache uses the provided queue for synchronous thread-safe access
    public init(on worker: Worker) {
        self.eventLoop = worker.eventLoop
        self.lock = DispatchQueue(label: "codes.vapor.database-kit.memory-keyed-cache.lock")
        self.memory = DictionaryKeyedCache(on: worker)
    }

    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) -> Future<D?> where D: Decodable {
        let promise = eventLoop.newPromise(D?.self)
        lock.async {
            self.memory.get(type, forKey: key).cascade(promise: promise)
        }
        return promise.futureResult
    }

    /// Sets a new value in the cache
    public func set<E>(_ encodable: E, forKey key: String) -> Future<Void> where E: Encodable {
        let promise = eventLoop.newPromise(Void.self)
        lock.async {
            self.memory.set(encodable, forKey: key).cascade(promise: promise)
        }
        return promise.futureResult
    }

    /// Removes a value from the cache
    public func remove(_ key: String) -> Future<Void> {
        let promise = eventLoop.newPromise(Void.self)
        lock.async {
            self.memory.remove(key).cascade(promise: promise)
        }
        return promise.futureResult
    }
}

/// Stores key-value pair in a dictionary thread-safely
public final class DictionaryKeyedCache: KeyedCache {
    /// The underlying storage of this cache
    private var storage: [String: Any]

    /// The event loop to put futures on
    private let eventLoop: EventLoop

    /// The cache uses the provided queue for synchronous thread-safe access
    public init(on worker: Worker) {
        self.eventLoop = worker.eventLoop
        self.storage = [:]
    }

    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) -> Future<D?> where D: Decodable {
        return eventLoop.newSucceededFuture(result: storage[key] as? D)
    }

    /// Sets a new value in the cache
    public func set<E>(_ encodable: E, forKey key: String) -> Future<Void> where E: Encodable {
         storage[key] = encodable
        return .done(on: eventLoop)
    }

    /// Removes a value from the cache
    public func remove(_ key: String) -> Future<Void> {
        storage[key] = nil
        return .done(on: eventLoop)
    }
}
