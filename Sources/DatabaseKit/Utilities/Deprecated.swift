/// See `DatabasesConfig`.
@available(*, deprecated, renamed: "DatabasesConfig")
public typealias DatabaseConfig = DatabasesConfig

extension Database {
    // MARK: Deprecated

    /// See `Database.newConnection(on:)`.
    @available(*, deprecated, renamed: "newConnection(on:)")
    public func makeConnection(on worker: Worker) -> Future<Connection> {
        return newConnection(on: worker)
    }

    /// See `Database.newConnectionPool(on:worker:)`.
    @available(*, deprecated, renamed: "newConnectionPool(on:worker:)")
    public func makeConnectionPool(max: UInt, on worker: Worker) -> DatabaseConnectionPool<Self> {
        return newConnectionPool(config: DatabaseConnectionPoolConfig(maxConnections: numericCast(max)), on: worker)
    }
}

extension Container {
    // MARK: Deprecated

    /// See `Container.withNewConnection(to:closure:)`.
    @available(*, deprecated, renamed: "withNewConnection(to:closure:)")
    public func withConnection<Database, T>(to dbid: DatabaseIdentifier<Database>, closure: @escaping (Database.Connection) throws -> Future<T>) -> Future<T> {
        return withNewConnection(to: dbid, closure: closure)
    }

    /// See `Container.newConnection(to:)`.
    @available(*, deprecated, renamed: "newConnection(to:)")
    public func requestConnection<D>(to dbid: DatabaseIdentifier<D>) -> Future<D.Connection> {
        return newConnection(to: dbid)
    }

    /// See `DatabaseConnection.close()`.
    @available(*, deprecated, renamed: "close()")
    public func releaseConnection<D>(_ conn: D.Connection, to dbid: DatabaseIdentifier<D>) {
        return conn.close()
    }
}

extension KeyedCache {
    // MARK: Deprecated
    
    /// See `KeyedCache.get(_:as:)`.
    @available(*, deprecated, renamed: "get(_:as:)")
    public func get<D>(_ type: D.Type, forKey key: String) -> Future<D?> where D: Decodable {
        return get(key, as: D.self)
    }

    /// See `KeyedCache.set(_:to:)`.
    @available(*, deprecated, renamed: "set(_:to:)")
    public func set<E>(_ value: E, forKey key: String) -> Future<Void> where E: Encodable {
        return set(key, to: value)
    }
}
