import DatabaseKit
import Async

public final class DatabaseKeyedCache<DatabaseCache> where DatabaseCache: KeyedCacheSupporting {
    var pool: DatabaseConnectionPool<DatabaseCache>

    init(pool: DatabaseConnectionPool<DatabaseCache>) {
        self.pool = pool
    }

    /// Retreived a value from the cache
    public func get<D>(
        _ type: D.Type,
        forKey key: String
        ) throws -> Future<D?> where D: Decodable {
        return pool.requestConnection().flatMap(to: D?.self, { [weak self] conn in
            defer { self?.pool.releaseConnection(conn) }
            return try DatabaseCache.get(D.self, forKey: key, on: conn)
        })
    }

    /// Sets a new value in the cache
    public func set<E>(
        _ entity: E,
        forKey key: String
    ) throws -> Future<Void> where E: Encodable {
        return pool.requestConnection().flatMap(to: Void.self, { [weak self] conn in
            defer { self?.pool.releaseConnection(conn) }
            return try DatabaseCache.set(entity, forKey: key, on: conn)
        })
    }

    /// Removes a value from the cache
    public func remove(_ key: String, on connection: Worker) throws -> Future<Void> {
        return pool.requestConnection().flatMap(to: Void.self, { [weak self] conn in
            defer { self?.pool.releaseConnection(conn) }
            return try DatabaseCache.remove(key, on: conn)
        })
    }
}
