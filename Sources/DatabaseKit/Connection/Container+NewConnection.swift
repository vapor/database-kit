/// Create new connections to a database.
extension Container {
    // MARK: New
    
    /// Creates a new connection to the `Database` specified by the supplied `DatabaseIdentifier`.
    ///
    /// The connection is provided to the supplied callback and will be automatically closed when the
    /// future returned by the callback is completed.
    ///
    ///     app.withNewConnection(to: .psql) { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `newConnection(...)` to create a connection without using a callback.
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    ///     - closure: Callback that accepts the newly created `DatabaseConnection`.
    /// - returns: A future containing the result of the closure.
    public func withNewConnection<Database, T>(to dbid: DatabaseIdentifier<Database>, closure: @escaping (Database.Connection) throws -> Future<T>) -> Future<T> {
        return newConnection(to: dbid).flatMap(to: T.self) { conn in
            return try closure(conn).always {
                conn.close()
            }
        }
    }

    /// Creates a new connection to the `Database` specified by the supplied `DatabaseIdentifier`.
    ///
    /// The `DatabaseConnection` returned by this method should be closed when you are finished using it.
    ///
    ///     let conn = try app.newConnection(to: .psql).wait()
    ///     defer { conn.close() }
    ///     // use the connection
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    /// - returns: A future containing the newly created `DatabaseConnection`.
    public func newConnection<Database>(to dbid: DatabaseIdentifier<Database>) -> Future<Database.Connection> {
        do {
            return try make(Databases.self).requireDatabase(for: dbid).newConnection(on: eventLoop)
        } catch {
            return eventLoop.newFailedFuture(error: error)
        }
    }
}
