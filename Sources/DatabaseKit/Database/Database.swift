/// Types conforming to this protocol can be used as a database for connections and connection pools.
///
/// This protocol is the basis for `...Supporting` protocols that further extend it, such as `KeyedCacheSupporting`.
public protocol Database {
    /// This database's connection type. Protocols that extend `Database` should be implemented using
    /// static methods on this type that supplied an instance of `Connection`.
    associatedtype Connection: DatabaseConnection

    /// Creates a new `DatabaseConnection` that will perform async work on the supplied `Worker`.
    ///
    ///     let conn = try database.newConnection(on: ...).wait()
    ///
    /// - parameters:
    ///     - worker: `Worker` to perform async work on.
    func newConnection(on worker: Worker) -> Future<Connection>
}

extension Database {
    /// Creates a new `DatabaseConnectionPool` for this `Database`.
    ///
    ///     let pool = try database.newConnectionPool(config: .default(), on: ...).wait()
    ///     let conn = try pool.requestConnection().wait()
    ///
    /// - paramters:
    ///     - config: `DatabaseConnectionPoolConfig` that will be used to create the actual pool.
    ///     - worker: `Worker` to perform async work on.
    /// - returns: Newly created `DatabaseConnectionPool`.
    public func newConnectionPool(config: DatabaseConnectionPoolConfig, on worker: Worker) -> DatabaseConnectionPool<Self> {
        return DatabaseConnectionPool(config: config, database: self, on: worker)
    }
}
