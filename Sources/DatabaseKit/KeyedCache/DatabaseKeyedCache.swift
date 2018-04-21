/// `KeyedCacheSupporting` database implementation of `KeyedCache`.
public final class DatabaseKeyedCache<Database>: KeyedCache, Service
    where Database: KeyedCacheSupporting
{
    /// Pool to use for requesting connections.
    private let pool: DatabaseConnectionPool<Database>

    /// Creates a new `DatabaseKeyedCache` on the supplied pool.
    ///
    /// - pool: Use to generate connections for get, set, and remove commands.
    public init(pool: DatabaseConnectionPool<Database>) {
        self.pool = pool
    }

    /// See `KeyedCache`.
    public func get<D>(_ key: String, as decodable: D.Type) -> Future<D?> where D : Decodable {
        return pool.withConnection { conn in
            return try Database.keyedCacheGet(key, as: D.self, on: conn)
        }
    }

    /// See `KeyedCache`.
    public func set<E>(_ key: String, to encodable: E) -> Future<Void> where E : Encodable {
        return pool.withConnection { conn in
            return try Database.keyedCacheSet(key, to: encodable, on: conn)
        }
    }

    /// See `KeyedCache`.
    public func remove(_ key: String) -> Future<Void> {
        return pool.withConnection { conn in
            return try Database.keyedCacheRemove(key, on: conn)
        }
    }
}

extension Container {
    /// Creates a `DatabaseKeyedCache` for the identified `Database`.
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    public func keyedCache<Database>(for dbid: DatabaseIdentifier<Database>) throws -> DatabaseKeyedCache<Database> {
        return try DatabaseKeyedCache(pool: connectionPool(to: dbid))
    }
}
