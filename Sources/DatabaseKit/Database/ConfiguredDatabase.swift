/// Makes new connections for the underlying generic `Database` and configures them according to the
/// options specified by `DatabaseConfig`. This may include things like enabling logging on the
/// connection or setting up foreign key enforcement.
///
/// See `DatabaseConfig` and `Databases`.
public struct ConfiguredDatabase<D>: Database where D: Database {
    /// Underlying `Database`.
    public let database: D

    /// Configures new `Database` connections.
    private var config: ConnectionConfig<D>

    /// Creates a new `ConnectionConfig`.
    init(database: D, config: ConnectionConfig<D>) {
        self.database = database
        self.config = config
    }

    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<D.Connection> {
        return database.newConnection(on: worker).then { conn in
            return self.config.pipeline.map { config -> LazyFuture<Void> in
                return { config(self.database, conn) }
            }.syncFlatten(on: worker).transform(to: conn)
        }
    }
}

extension ConfiguredDatabase: KeyedCacheSupporting where D: KeyedCacheSupporting {
    // MARK: Keyed Cache

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheGet<T>(_ key: String, as decodable: T.Type, on conn: Connection) throws -> Future<T?>
        where T: Decodable
    {
        return try D.keyedCacheGet(key, as: T.self, on: conn)
    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheSet<E>(_ key: String, to encodable: E, on conn: D.Connection) throws -> Future<Void>
        where E: Encodable
    {
        return try D.keyedCacheSet(key, to: encodable, on: conn)
    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheRemove(_ key: String, on conn: D.Connection) throws -> Future<Void> {
        return try D.keyedCacheRemove(key, on: conn)
    }
}

// MARK: Internal

/// Holds an array of closures that should run to configure each new connection.
internal struct ConnectionConfig<D> where D: Database {
    /// Array of configuration closures.
    var pipeline: [(D, D.Connection) -> Future<Void>]

    /// Creates a new `ConnectionConfig`.
    init() {
        self.pipeline = []
    }
}
