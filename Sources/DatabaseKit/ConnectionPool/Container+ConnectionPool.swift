/// Create pooled connections that are automatically released when done.
extension Container {
    // MARK: Pooled

    /// Fetches a pooled connection to the `Database` specified by the supplied `DatabaseIdentifier`.
    ///
    /// The connection is provided to the supplied callback and will be automatically released when the
    /// future returned by the callback is completed.
    ///
    ///     app.withPooledConnection(to: .psql) { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `requestPooledConnection(...)` to request a pooled connection without using a callback.
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    ///     - closure: Callback that accepts the pooled `DatabaseConnection`.
    /// - returns: A future containing the result of the closure.
    public func withPooledConnection<Database, T>(to dbid: DatabaseIdentifier<Database>, closure: @escaping (Database.Connection) throws -> Future<T>) -> Future<T> {
        do {
            return try connectionPool(to: dbid).withConnection(closure)
        } catch {
            return eventLoop.newFailedFuture(error: error)
        }
    }

    /// Requests a pooled connection to the `Database` specified by the supplied `DatabaseIdentifier`.
    ///
    /// The `DatabaseConnection` returned by this method should be released when you are finished using it.
    ///
    ///     let conn = try app.requestPooledConnection(to: .psql).wait()
    ///     defer { app.releasePooledConnection(conn, to: .psql) }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    /// - returns: A future containing the pooled `DatabaseConnection`.
    public func requestPooledConnection<Database>(to dbid: DatabaseIdentifier<Database>) -> Future<Database.Connection> {
        do {
            return try connectionPool(to: dbid).requestConnection()
        } catch {
            return eventLoop.newFailedFuture(error: error)
        }
    }

    /// Releases a connection back to the pool. Used with `requestPooledConnection(...)`.
    ///
    ///     let conn = try app.requestPooledConnection(to: .psql).wait()
    ///     defer { app.releasePooledConnection(conn, to: .psql) }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - conn: `DatabaseConnection` to release back to the pool.
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    public func releasePooledConnection<Database>(_ conn: Database.Connection, to dbid: DatabaseIdentifier<Database>) throws {
        /// this is the first attempt to connect to this
        /// db for this request
        try connectionPool(to: dbid).releaseConnection(conn)
    }


    /// Creates a `DatabaseConnectionPool` for the identified `Database`.
    /// Subsequent calls to this method will always return the same pool.
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    /// - returns: A `DatabaseConnectionPool` for the identified `Database`.
    public func connectionPool<Database>(to dbid: DatabaseIdentifier<Database>) throws -> DatabaseConnectionPool<ConfiguredDatabase<Database>> {
        let cache = try self.make(DatabaseConnectionPoolCache.self)
        return try cache.requirePool(for: dbid)
    }
}
