/// Caches `DatabaseConnectionPool`s on a `Container`.
internal final class DatabaseConnectionPoolCache: ServiceType {
    /// See `ServiceType`.
    static func makeService(for container: Container) throws -> DatabaseConnectionPoolCache {
        return try DatabaseConnectionPoolCache(databases: container.make(), config: container.make(), on: container)
    }

    /// The source databases.
    private let databases: Databases

    /// The cached connection pools.
    private var cache: [String: Any]

    /// The container to use.
    private let eventLoop: EventLoop

    /// The pool configuration settings.
    private let config: DatabaseConnectionPoolConfig

    /// Creates a new `DatabaseConnectionPoolCache`.
    internal init(databases: Databases, config: DatabaseConnectionPoolConfig, on worker: Worker) {
        self.databases = databases
        self.eventLoop = worker.eventLoop
        self.config = config
        self.cache = [:]
    }

    /// Fetches the `DatabaseConnectionPool` for the identified `Database`.
    internal func requirePool<D>(for dbid: DatabaseIdentifier<D>) throws -> DatabaseConnectionPool<ConfiguredDatabase<D>>
    {
        if let existing = cache[dbid.uid] as? DatabaseConnectionPool<ConfiguredDatabase<D>> {
            return existing
        } else {
            let new = try databases.requireDatabase(for: dbid).newConnectionPool(config: config, on: eventLoop)
            cache[dbid.uid] = new
            return new
        }
    }
}
