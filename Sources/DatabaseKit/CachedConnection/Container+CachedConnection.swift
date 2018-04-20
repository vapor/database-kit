/// Request / release cached database connections.
extension Container {
    /// Returns a future connection to the supplied database.
    ///
    /// Subsequent calls to this method with the same database ID will
    /// return the same connection.
    ///
    /// You must call `.releaseCachedConnections()` to release the connections.
    public func requestCachedConnection<Database>(to database: DatabaseIdentifier<Database>) -> Future<Database.Connection> {
        return Future.flatMap(on: self) {
            let connections = try self.make(ActiveDatabaseConnectionCache.self)
            if let current = connections.cache[database.uid]?.connection as? Future<Database.Connection> {
                return current
            }

            /// create an active connection, since we don't have to worry about threading
            /// we can be sure that .connection will be set before this is called again
            let active = ActiveDatabaseConnection()
            connections.cache[database.uid] = active

            /// first get a pointer to the pool
            let pool = try self.connectionPool(to: database)
            let conn = pool.requestConnection().map(to: Database.Connection.self) { conn in
                /// then create an active connection that knows how to
                /// release itself
                active.release = {
                    pool.releaseConnection(conn)
                }

                return conn
            }
            /// set the active connection so it is returned next time
            active.connection = conn
            return conn
        }
    }

    /// Releases all connections created by calls to `.requestCachedConnection(to:)`.
    public func releaseCachedConnections() throws {
        let connections = try make(ActiveDatabaseConnectionCache.self)
        let conns = connections.cache
        connections.cache = [:]
        for (_, conn) in conns {
            guard let release = conn.release else {
                ERROR("Release callback not set.")
                continue
            }
            release()
        }
    }
}

