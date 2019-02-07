import NIO

/// Types conforming to this protocol can be used as a database for connections and connection pools.
///
/// This protocol is the basis for `...Supporting` protocols that further extend it, such as `KeyedCacheSupporting`.
public protocol Database: ConnectionPoolSource where Connection: DatabaseConnection { }

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
    public func makeConnectionPool(config: ConnectionPoolConfig) -> ConnectionPool<Self> {
        return ConnectionPool(config: config, source: self)
    }
}


extension Database {
    public func withConnection<Result>(closure: @escaping (Connection) -> EventLoopFuture<Result>) -> EventLoopFuture<Result> {
        return self.makeConnection().flatMap { conn -> EventLoopFuture<Result> in
            return closure(conn).flatMap { result in
                return conn.close().map { result }
            }.flatMapError { error in
                return conn.close().flatMapThrowing { throw error }
            }
        }
    }
}
