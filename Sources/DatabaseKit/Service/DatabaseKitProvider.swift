import Service

/// Registers database kit services.
public final class DatabaseKitProvider: Provider {
    /// See Provider.repositoryName
    public static let repositoryName = "database-kit"

    /// Creates a new `DatabaseKitProvider`
    public init() {}

    /// See Provider.register
    public func register(_ services: inout Services) throws {
        services.register(isSingleton: true) { container -> Databases in
            let config = try container.make(DatabaseConfig.self, for: DatabaseKitProvider.self)
            var databases: [String: Any] = [:]
            for (id, lazyDatabase) in config.databases {
                let db = try lazyDatabase(container)
                if let supports = db as? LogSupporting, let logger = config.logging[id] {
                    logger.dbID = id
                    supports.enableLogging(using: logger)
                }
                databases[id] = db
            }
            return Databases(databases)
        }

        services.register(isSingleton: true) { worker -> DatabaseConnectionPoolCache in
            return try DatabaseConnectionPoolCache(
                databases: worker.make(for: DatabaseConnectionPoolCache.self),
                maxConnections: 2, // make this configurable
                on: worker.eventLoop
            )
        }

        services.register(isSingleton: true) { worker -> ActiveDatabaseConnectionCache in
            return ActiveDatabaseConnectionCache()
        }
    }

    /// See Provider.boot
    public func boot(_ worker: Container) throws {
        //
    }
}
