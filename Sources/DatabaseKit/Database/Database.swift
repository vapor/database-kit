/// Types conforming to this protocol can be used as
/// a database for Fluent connections and connection pools.
public protocol Database {
    /// This database's connection type.
    /// The connection should also know which
    /// type of database it belongs to.
    associatedtype Connection: DatabaseConnection

    /// Creates a new database connection that will
    /// execute callbacks on the supplied dispatch queue.
    func newConnection(on worker: Worker) -> Future<Connection>
}

extension Database {
    /// Creates a new `DatabaseConnectionPool` for this `Database`.
    public func newConnectionPool(config: DatabaseConnectionPoolConfig, on worker: Worker) -> DatabaseConnectionPool<Self> {
        return DatabaseConnectionPool(config: config, database: self, on: worker)
    }
}
