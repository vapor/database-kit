/// In-memory, thread safe `KeyedCache` implementation.
///
/// See `DictionaryKeyedCache` for a non-threadsafe implementation.
public final class MemoryKeyedCache: KeyedCache, Service {
    /// The event loop to put futures on.
    private let eventLoop: EventLoop

    /// Sync access to the memory.
    private let lock: DispatchQueue

    /// Underlying memory.
    private let memory: DictionaryKeyedCache

    /// Creates a new `MemoryKeyedCache`.
    public init() {
        // no actual async work is being done, so we can just use `EmbeddedEventLoop`
        self.eventLoop = EmbeddedEventLoop()
        self.lock = DispatchQueue(label: "codes.vapor.database-kit.memory-keyed-cache.lock")
        self.memory = DictionaryKeyedCache(on: eventLoop)
    }

    /// See `KeyedCache`.
    public func get<D>(_ key: String, as decodable: D.Type) -> Future<D?> where D : Decodable {
        let promise = eventLoop.newPromise(D?.self)
        lock.async {
            self.memory.get(key, as: D.self).cascade(promise: promise)
        }
        return promise.futureResult
    }

    /// See `KeyedCache`.
    public func set<E>(_ key: String, to encodable: E) -> Future<Void> where E : Encodable {
        let promise = eventLoop.newPromise(Void.self)
        lock.async {
            self.memory.set(key, to: encodable).cascade(promise: promise)
        }
        return promise.futureResult
    }

    /// See `KeyedCache`.
    public func remove(_ key: String) -> Future<Void> {
        let promise = eventLoop.newPromise(Void.self)
        lock.async {
            self.memory.remove(key).cascade(promise: promise)
        }
        return promise.futureResult
    }
}
