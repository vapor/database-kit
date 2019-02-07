/// Helper struct for configuring the `Databases` struct.
public struct Databases {
    /// The configured databases.
    private var storage: [String: Any]

    /// Create a new database config helper.
    public init() {
        self.storage = [:]
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
        assert(self.storage[id.uid] == nil, "A database with id '\(id.uid)' is already registered.")
        self.storage[id.uid] = database
    }
    
    /// Fetches the `Database` for a given `DatabaseIdentifier`.
    ///
    ///     let psql = try databases.requireDatabase(for: .psql)
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` of the `Database` to fetch.
    /// - throws: Throws an error if no `Database` with that id was found.
    /// - returns: `Database` identified by the supplied ID.
    public func requireDatabase<D>(for dbid: DatabaseIdentifier<D>) throws -> D {
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
    public func database<D>(for dbid: DatabaseIdentifier<D>) -> D? {
        guard let db = self.storage[dbid.uid] as? D else {
            return nil
        }
        return db
    }
}
