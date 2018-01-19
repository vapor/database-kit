import Async

/// Stores key-value pair in a dictionary thread-safely
public final class MemoryKeyedCache: KeyedCache {
    /// The underlying storage of this cache
    var storage = [String: Any]()

    /// The cache uses the provided queue for synchronous thread-safe access
    public init() {}

    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?> where D: Decodable {
        return Future(storage[key] as? D)
    }

    /// Sets a new value in the cache
    public func set(_ entity: Encodable, forKey key: String) throws -> Future<Void> {
        storage[key] = entity
        return .done
    }

    /// Removes a value from the cache
    public func remove(_ key: String) throws -> Future<Void> {
        storage[key] = nil
        return .done
    }
}
