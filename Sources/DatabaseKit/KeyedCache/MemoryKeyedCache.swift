import Async
import Dispatch

/// Stores key-value pair in a dictionary thread-safely
public final class MemoryKeyedCache: KeyedCache {
    /// The underlying storage of this cache
    private var storage = [String: Any]()

    /// The event loop to put futures on
    private let eventLoop: EventLoop

    /// Sync access
    private let lock: DispatchQueue

    /// The cache uses the provided queue for synchronous thread-safe access
    public init(on worker: Worker = EmbeddedEventLoop()) {
        self.eventLoop = worker.eventLoop
        self.lock = DispatchQueue(label: "codes.vapor.database-kit.memory-keyed-cache.lock")
    }

    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?> where D: Decodable {
        let promise = eventLoop.newPromise(D?.self)
        lock.sync { promise.succeed(result: storage[key] as? D) }
        return promise.futureResult
    }

    /// Sets a new value in the cache
    public func set<E>(_ entity: E, forKey key: String) throws -> Future<Void> where E: Encodable {
        lock.sync { storage[key] = entity }
        return .done(on: eventLoop)
    }

    /// Removes a value from the cache
    public func remove(_ key: String) throws -> Future<Void> {
        lock.sync { storage[key] = nil }
        return .done(on: eventLoop)
    }
}
