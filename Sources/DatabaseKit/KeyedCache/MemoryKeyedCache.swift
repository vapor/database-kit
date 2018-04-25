/// In-memory, thread safe `KeyedCache` implementation.
///
/// - warning: This implementation uses locks and is meant for testing and development.
///            Use a service like Redis or Memcached instead. This class is not suitable for production.
///
/// See `DictionaryKeyedCache` for a non-threadsafe implementation.
public final class MemoryKeyedCache: KeyedCache, Service {
    /// Sync access to the memory.
    private let lock: NSLock

    /// Underlying memory.
    private let memory: DictionaryKeyedCache

    /// Creates a new `MemoryKeyedCache`.
    public init() {
        // no actual async work is being done, so we can just use `EmbeddedEventLoop`
        self.lock = .init()
        self.memory = DictionaryKeyedCache()
    }

    /// See `KeyedCache`.
    public func get<D>(_ key: String, as decodable: D.Type) -> Future<D?> where D : Decodable {
        lock.lock()
        defer { lock.unlock() }
        return memory.get(key, as: D.self)
    }

    /// See `KeyedCache`.
    public func set<E>(_ key: String, to encodable: E) -> Future<Void> where E : Encodable {
        lock.lock()
        defer { lock.unlock() }
        return memory.set(key, to: encodable)
    }

    /// See `KeyedCache`.
    public func remove(_ key: String) -> Future<Void> {
        lock.lock()
        defer { lock.unlock() }
        return memory.remove(key)
    }
}
