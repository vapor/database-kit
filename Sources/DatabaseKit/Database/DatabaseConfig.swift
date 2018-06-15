/// Helper struct for configuring the `Databases` struct.
public struct DatabasesConfig: Service {
    /// The configured databases.
    private var lazyDatabases: [String: (Container) throws -> Any]

    /// Array of connection configuration.
    private var connectionConfig: [String: Any]

    /// Create a new database config helper.
    public init() {
        self.lazyDatabases = [:]
        self.connectionConfig = [:]
    }

    // MARK: Database

    /// Add a pre-initialized database to the config.
    ///
    ///     let psql: PostgreSQLDatabase = ...
    ///     databases.add(database: psql, as: .psql)
    ///
    /// - parameters:
    ///     - database: Initialized instance of a `Database` to add.
    ///     - id: `DatabaseIdentifier` to use for this `Database`.
    public mutating func add<D>(database: D, as id: DatabaseIdentifier<D>) {
        assert(lazyDatabases[id.uid] == nil, "A database with id '\(id.uid)' is already registered.")
        lazyDatabases[id.uid] = { _ in database }
    }


    /// Add a database type to the config. This database type will be requested from
    /// the container once the application boots.
    ///
    ///     databases.add(database: PostgreSQLDatabase.self, as: .psql)
    ///
    /// - parameters:
    ///     - database: Type of a `Database` to add.
    ///     - id: `DatabaseIdentifier` to use for this `Database`.
    public mutating func add<D>(database: D.Type, as id: DatabaseIdentifier<D>) {
        assert(lazyDatabases[id.uid] == nil, "A database with id '\(id.uid)' is already registered.")
        lazyDatabases[id.uid] = { try $0.make(D.self) }
    }

    /// Add a lazy database to the config. This closure will be run when the application boots.
    ///
    ///     databases.add(as: .psql) { container in
    ///         return ...
    ///     }
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` to use for this `Database`.
    ///     - database: Closure accepting a `Container` and returning a `Database`.
    public mutating func add<D>(as id: DatabaseIdentifier<D>, database: @escaping (Container) throws -> D) {
        assert(lazyDatabases[id.uid] == nil, "A database with id '\(id.uid)' is already registered.")
        lazyDatabases[id.uid] = database
    }

    // MARK: Logging

    /// Enables logging on the identified `Database`.
    ///
    ///     databases.enableLogging(on: .psql)
    ///
    /// - parameters:
    ///     - database: `DatabaseIdentifier` identifying the database to enable logging on.
    ///     - logger: Instance of `DatabaseLogHandler` to use.
    public mutating func enableLogging<D>(on db: DatabaseIdentifier<D>, logger: DatabaseLogHandler = PrintLogHandler()) where D: LogSupporting {
        let logger = DatabaseLogger(database: db, handler: logger)
        var config = connectionConfig[db.uid] as? ConnectionConfig<D> ?? .init()
        config.pipeline.append { conn in
            D.enableLogging(logger, on: conn)
            return .done(on: conn)
        }
        connectionConfig[db.uid] = config
    }
    
    /// Adds a new configuration handler to the referenced database.
    ///
    ///     databases.addConfigurationHandler(on: .sqlite) { sqliteConn in
    ///         // configure conn
    ///     }
    ///
    /// - parameters:
    ///     - database: `DatabaseIdentifier` identifying the database to configure.
    ///     - configure: Handles incoming connections, returns a future indicating completion.
    public mutating func appendConfigurationHandler<D>(on db: DatabaseIdentifier<D>, _ configure: @escaping (D.Connection) -> Future<Void>) {
        var config = connectionConfig[db.uid] as? ConnectionConfig<D> ?? .init()
        config.pipeline.append { conn in
            return configure(conn)
        }
        connectionConfig[db.uid] = config
    }

    // MARK: Resolve

    /// Resolves the currently configured databases to a `Databases` struct.
    ///
    /// - parameters:
    ///     - container: `Container` to resolve the databases on.
    public func resolve(on container: Container) throws -> Databases {
        var databases: [String: Any] = [:]
        for (id, lazyDatabase) in lazyDatabases {
            databases[id] = try lazyDatabase(container)
        }
        return Databases(storage: databases, connectionConfig: connectionConfig)
    }
}
