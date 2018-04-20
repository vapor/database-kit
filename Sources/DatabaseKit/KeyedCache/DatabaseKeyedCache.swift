public final class DatabaseKeyedCache<Database>: KeyedCache
    where Database: KeyedCacheSupporting
{
    private let pool: DatabaseConnectionPool<Database>

    public init(pool: DatabaseConnectionPool<Database>) {
        self.pool = pool
    }

    /// Retreived a value from the cache
    public func get<D>(_ decodable: D.Type, forKey key: String) -> Future<D?> where D: Decodable {
        return pool.withConnection { conn in
            return try Database.keyedCacheGet(D.self, forKey: key, on: conn)
        }
    }

    /// Sets a new value in the cache
    public func set<E>(_ encodable: E, forKey key: String) -> Future<Void> where E: Encodable {
        return pool.withConnection { conn in
            return try Database.keyedCacheSet(encodable, forKey: key, on: conn)
        }
    }

    /// Removes a value from the cache
    public func remove(_ key: String) -> Future<Void> {
        return pool.withConnection { conn in
            return try Database.keyedCacheRemove(key, on: conn)
        }
    }
}
