/// Containers that have `DatabasesConfig` structs registered can be used to open, pool, and cache connections.
extension Container {
    // MARK: Cached
    
    /// Returns a Future connection to the `Database` specified by the supplied `DatabaseIdentifier`.
    /// Subsequent calls to this method with the same database ID will return the same connection.
    /// You must call `releaseCachedConnections()` to release the connections.
    ///
    ///     let conn = try app.requestCachedConnection(to: .psql).wait()
    ///     // use conn
    ///     try app.releaseCachedConnections()
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    /// - returns: A future containing the `DatabaseConnection`.
    public func requestCachedConnection<Database>(to database: DatabaseIdentifier<Database>) -> Future<Database.Connection> {
        do {
            /// use the container to create a connection cache
            /// this must have been registered with the services
            let connections = try make(DatabaseConnectionCache.self)
            if let current = connections.cache[database.uid]?.connection as? Future<Database.Connection> {
                return current
            }

            /// create an active connection, since we don't have to worry about threading
            /// we can be sure that .connection will be set before this is called again
            let active = CachedDatabaseConnection()
            connections.cache[database.uid] = active

            /// first get a pointer to the pool
            let pool = try connectionPool(to: database)
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
        } catch {
            return eventLoop.newFailedFuture(error: error)
        }
    }

    /// Releases all connections created by calls to `requestCachedConnection(to:)`.
    public func releaseCachedConnections() throws {
        let connections = try make(DatabaseConnectionCache.self)
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

// MARK: Cache Types

/// Caches active database connections. Powers `Container.requestCachedConnection(...)`.
internal final class DatabaseConnectionCache: ServiceType {
    /// Private storage
    fileprivate var cache: [String: CachedDatabaseConnection]

    /// Creates a new `DatabaseConnectionCache`
    private init() {
        self.cache = [:]
    }

    /// See `ServiceType`.
    static func makeService(for worker: Container) throws -> DatabaseConnectionCache {
        return .init()
    }
}

/// Holds an active connection. Used by `DatabaseConnectionCache`.
private final class CachedDatabaseConnection {
    /// Handles connection release
    typealias OnRelease = () -> ()

    /// The unsafely typed connection
    var connection: Any?

    /// Call this on release
    var release: OnRelease?

    /// Creates a new `ActiveDatabaseConnection`
    init() {}
}
