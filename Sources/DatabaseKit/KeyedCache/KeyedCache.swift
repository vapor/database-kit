/// A key-value cache.
public protocol KeyedCache {
    /// Gets an instance of decodable type `D` parsed from the value associated with the `key`
    ///
    ///     let res = cache.get("hello", as: String.self).wait()
    ///     print(res) // String?
    ///
    /// - parameters:
    ///     - key: Cache key to access.
    ///     - decodable: Decodable type `D` to decode.
    /// - returns: A future containing an optional value of `D`, nil if no value was found.
    func get<D>(_ key: String, as decodable: D.Type) -> Future<D?>
        where D: Decodable

    /// Sets the value to an encodable object at the supplied `key`.
    ///
    ///     try cache.set("world", forKey: "hello").wait()
    ///
    /// - parameters:
    ///     - key: Cache key to set.
    ///     - encodable: An `Encodable` item to set.
    /// - returns: A future that completes when the action finishes. May also contain an error.
    func set<E>(_ key: String, to encodable: E) -> Future<Void>
        where E: Encodable

    /// Removes the value associated with the `key`.
    ///
    ///     try cache.remove("hello")
    ///
    /// - returns: A future that completes when the action finishes. May also contain an error.
    func remove(_ key: String) -> Future<Void>
}

extension KeyedCache {
    /// Gets an instance of decodable type `D` parsed from the value associated with the `key`
    ///
    ///     let res: String? = cache.get("hello").wait()
    ///     print(res) // String?
    ///
    /// - parameters:
    ///     - key: Cache key to access.
    /// - returns: A future containing an optional value of `D`, nil if no value was found.
    func get<D>(_ key: String) -> Future<D?> where D: Decodable {
        return get(key, as: D.self)
    }
}
