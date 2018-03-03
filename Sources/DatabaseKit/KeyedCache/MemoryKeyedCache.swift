import Async

/// Stores key-value pair in a dictionary thread-safely
public final class MemoryKeyedCache: KeyedCache {
    /// The underlying storage of this cache
    var storage = [String: Any]()

    /// The event loop
    let eventLoop: EventLoop

    /// The cache uses the provided queue for synchronous thread-safe access
    public init(on worker: Worker) {
        self.eventLoop = worker.eventLoop
    }

    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?> where D: Decodable {
        let promise = eventLoop.newPromise(D?.self)
        promise.succeed(result: storage[key] as? D)
        return promise.futureResult
    }

    /// Sets a new value in the cache
    public func set<E>(_ entity: E, forKey key: String) throws -> Future<Void> where E: Encodable {
        storage[key] = entity
        return .done(on: eventLoop)
    }

    /// Removes a value from the cache
    public func remove(_ key: String) throws -> Future<Void> {
        storage[key] = nil
        return .done(on: eventLoop)
    }
}
