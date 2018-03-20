import Async
import Service

/// Create pooled connections that are automatically released when done.
extension Container {
    /// Returns a future database connection for the
    /// supplied database identifier if one can be fetched.
    /// The database connection will be cached on this worker.
    /// The same database connection will always be returned for
    /// a given worker.
    public func withPooledConnection<Database, T>(
        to database: DatabaseIdentifier<Database>,
        closure: @escaping (Database.Connection) throws -> Future<T>
    ) -> Future<T> {
        return requestPooledConnection(to: database).flatMap(to: T.self) { conn in
            return try closure(conn).map(to: T.self) { res in
                try self.releasePooledConnection(conn, to: database)
                return res
            }
        }
    }
}

/// Request / release connections from this container's connection pool.
extension Container {
    /// Requests a connection to the database.
    ///
    /// You must be sure to call `.releasePooledConnection(_:to:)` with
    /// the requested connection when you are finished using it.
    public func requestPooledConnection<Database>(
        to database: DatabaseIdentifier<Database>
    ) -> Future<Database.Connection> {
        return Future.flatMap(on: self) {
            /// request a connection from the pool
            return try self.connectionPool(to: database).requestConnection()
        }
    }

    /// Releases a connection back to the pool.
    public func releasePooledConnection<Database>(
        _ conn: Database.Connection,
        to database: DatabaseIdentifier<Database>
    ) throws {
        /// this is the first attempt to connect to this
        /// db for this request
        try connectionPool(to: database).releaseConnection(conn)
    }
}

/// MARK: Internal

extension Container {
    /// Creates a `DatabaseConnectionPool` for the supplied Database identifier.
    /// Subsequent calls to this method will always return the same pool.
    public func connectionPool<Database>(
        to database: DatabaseIdentifier<Database>
    ) throws -> DatabaseConnectionPool<Database> {
        let cache = try self.make(DatabaseConnectionPoolCache.self)
        return try cache.pool(for: database)
    }
}
