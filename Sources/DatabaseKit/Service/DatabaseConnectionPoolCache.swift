import Service

/// Caches database connection pools.
/// This is stored on an event loop to allow connection pool re-use.
internal final class DatabaseConnectionPoolCache {
    /// The source databases.
    private let databases: Databases

    /// The cached connection pools.
    private var cache: [String: Any]

    /// The container to use.
    private let container: Container

    /// Maximum connections.
    private let maxConnections: UInt

    /// Creates a new connection pool cache for the supplied
    /// databases using a given container.
    internal init(databases: Databases, on container: Container, maxConnections: UInt) {
        self.databases = databases
        self.container = container
        self.maxConnections = maxConnections
        self.cache = [:]
    }

    /// Fetches the existing DatabaseConnectionPool for the supplied id
    /// or creates a new one.
    internal func pool<D>(for id: DatabaseIdentifier<D>) throws -> DatabaseConnectionPool<D>
    {
        if let existing = cache[id.uid] as? DatabaseConnectionPool<D> {
            return existing
        } else {
            guard let database = databases.database(for: id) else {
                fatalError("no database")
            }

            let new = try database.makeConnectionPool(
                max: maxConnections,
                using: container.make(for: D.Connection.self),
                on: container
            )
            cache[id.uid] = new
            return new
        }
    }
}

