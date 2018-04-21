/// See `DatabasesConfig`.
@available(*, deprecated, renamed: "DatabasesConfig")
public typealias DatabaseConfig = DatabasesConfig

extension Database {
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
    /// See `Container.withNewConnection(to:closure:)`.
    @available(*, deprecated, renamed: "withNewConnection(to:closure:)")
    public func withConnection<Database, T>(to dbid: DatabaseIdentifier<Database>, closure: @escaping (Database.Connection) throws -> Future<T>) -> Future<T> {
        return withNewConnection(to: dbid, closure: closure)
    }
}