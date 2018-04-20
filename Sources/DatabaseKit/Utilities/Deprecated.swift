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
        return newConnectionPool(max: numericCast(max), on: worker)
    }
}
