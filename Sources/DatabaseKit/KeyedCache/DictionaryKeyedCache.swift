/// In-memory, non-threadsafe `KeyedCache` implementation.
///
/// See `MemoryKeyedCache` for a thread-safe implementation.
public final class DictionaryKeyedCache: KeyedCache, ServiceType {
    /// See `ServiceType`.
    public static var serviceSupports: [Any.Type] {
        return [KeyedCache.self]
    }

    /// See `ServiceType`.
    public static func makeService(for container: Container) throws -> Self {
        return .init()
    }

    /// The underlying storage of this cache.
    private var storage: [String: Any]

    /// The event loop to put futures on.
    private let eventLoop: EventLoop

    /// Creates a new `DictionaryKeyedCache`.
    public init() {
        // no actual async work is being done, so we can just use `EmbeddedEventLoop`
        self.eventLoop = EmbeddedEventLoop()
        self.storage = [:]
    }

    /// See `KeyedCache`.
    public func get<D>(_ key: String, as decodable: D.Type) -> Future<D?> where D : Decodable {
        return eventLoop.newSucceededFuture(result: storage[key] as? D)
    }

    /// See `KeyedCache`.
    public func set<E>(_ key: String, to encodable: E) -> Future<Void> where E : Encodable {
        storage[key] = encodable
        return eventLoop.newSucceededFuture(result: ())
    }

    /// See `KeyedCache`.
    public func remove(_ key: String) -> Future<Void> {
        storage[key] = nil
        return eventLoop.newSucceededFuture(result: ())
    }
}
