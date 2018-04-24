/// A `Database` that supports key-value actions.
public protocol KeyedCacheSupporting: Database {
    /// Gets an instance of decodable type `D` parsed from the value associated with the `key`
    static func keyedCacheGet<D>(_ key: String, as decodable: D.Type, on conn: Self.Connection) throws -> Future<D?>
        where D: Decodable

    /// Sets the value to an encodable object at the supplied `key`.
    static func keyedCacheSet<E>(_ key: String, to encodable: E, on conn: Self.Connection) throws -> Future<Void>
        where E: Encodable

    /// Removes the value associated with the `key`.
    static func keyedCacheRemove(_ key: String, on conn: Self.Connection) throws -> Future<Void>
}
