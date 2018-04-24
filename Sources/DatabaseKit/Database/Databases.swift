/// Represents an application's configured databases (zero or more).
public struct Databases: ServiceType {
    /// See `ServiceType`.
    public static func makeService(for container: Container) throws -> Databases {
        return try container.make(DatabasesConfig.self).resolve(on: container)
    }

    /// Private storage: `[DatabaseIdentifier: Database]`
    private let storage: [String: Any]

    /// Private storage: `[DatabaseIdentifier: ConnectionConfig]`
    private let connectionConfig: [String: Any]

    /// Private init: creates a new `Databases` struct.
    internal init(storage: [String: Any], connectionConfig: [String: Any]) {
        self.storage = storage
        self.connectionConfig = connectionConfig
    }

    /// Fetches the `Database` for a given `DatabaseIdentifier`.
    ///
    ///     let psql = try databases.requireDatabase(for: .psql)
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` of the `Database` to fetch.
    /// - throws: Throws an error if no `Database` with that id was found.
    /// - returns: `Database` identified by the supplied ID.
    public func requireDatabase<D>(for dbid: DatabaseIdentifier<D>) throws -> AnyDatabase<D> {
        guard let db = database(for: dbid) else {
            throw DatabaseKitError(identifier: "dbRequired", reason: "No database with id '\(dbid.uid)' is configured.")
        }
        return db
    }

    /// Fetches the `Database` for a given `DatabaseIdentifier`.
    ///
    ///     let psql = databases.database(for: .psql)
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` of the `Database` to fetch.
    /// - returns: `Database` identified by the supplied ID, if one could be found.
    public func database<D>(for dbid: DatabaseIdentifier<D>) -> AnyDatabase<D>? {
        guard let db = storage[dbid.uid] as? D else {
            return nil
        }
        let config = connectionConfig[dbid.uid] as? ConnectionConfig<D> ?? .init()
        return ConfiguredDatabase(config: config, base: db).anyDatabase()
    }
}

// MARK: Internal

/// Makes new connections for the underlying generic `Database` and configures them according to the
/// options specified by `DatabaseConfig`. This may include things like enabling logging on the
/// connection or setting up foreign key enforcement.
fileprivate struct ConfiguredDatabase<D>: Database where D: Database {
    let config: ConnectionConfig<D>
    let base: D
    func newConnection(on worker: Worker) -> EventLoopFuture<D.Connection> {
        return base.newConnection(on: worker).then { conn in
            return self.config.pipeline.map { config -> LazyFuture<Void> in
                return { config(conn) }
            }.syncFlatten(on: worker).transform(to: conn)
        }
    }
}

/// Holds an array of closures that should run to configure each new connection.
internal struct ConnectionConfig<D> where D: Database {
    /// Array of configuration closures.
    var pipeline: [(D.Connection) -> Future<Void>]

    /// Creates a new `ConnectionConfig`.
    init() {
        self.pipeline = []
    }
}
