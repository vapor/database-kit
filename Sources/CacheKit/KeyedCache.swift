import Async

/// A key-value cache
public protocol KeyedCache {
    /// Gets the value as type `D` deserialized from the value associated with the `key`
    ///
    /// Returns an empty future that triggers on successful storage
    func get<D>(_ type: D.Type, forKey key: String) throws -> Future<D?>
    where D: Decodable

    /// Sets the value to `entity` stored associated with the `key`
    ///
    /// Returns an empty future that triggers on successful storage
    func set<E>(_ entity: E, forKey key: String) throws -> Future<Void>
    where E: Encodable

    /// Removes the value associated with the `key`
    func remove(_ key: String) throws -> Future<Void>
}
