import Async
import DatabaseKit

/// A key-value cache
public protocol KeyedCacheSupporting: Database {
    /// Gets the value as type `D` deserialized from the value associated with the `key`
    ///
    /// Returns an empty future that triggers on successful storage
    static func get<D>(_ type: D.Type, forKey key: String, on conn: Self.Connection) throws -> Future<D?>
        where D: Decodable

    /// Sets the value to `entity` stored associated with the `key`
    ///
    /// Returns an empty future that triggers on successful storage
    static func set<E>(_ entity: E, forKey key: String, on conn: Self.Connection) throws -> Future<Void>
        where E: Encodable

    /// Removes the value associated with the `key`
    static func remove(_ key: String, on conn: Self.Connection) throws -> Future<Void>
}

