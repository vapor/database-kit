/// Used to configure `DatabaseConnectionPool`s created by your application.
public struct DatabaseConnectionPoolConfig: ServiceType {
    /// Creates a new `DatabaseConnectionPoolConfig` with default settings.
    public static func `default`() -> DatabaseConnectionPoolConfig {
        return .init(maxConnections: System.coreCount)
    }

    /// See `ServiceType`.
    public static func makeService(for worker: Container) throws -> DatabaseConnectionPoolConfig {
        return .default()
    }

    /// Maximum number of connections per pool.
    ///
    /// There will normally be multiple connection pools in your application,
    /// usually one per worker (where num workers = num logical CPU cores).
    ///
    /// The minimum supported value is `1`, meaning that your database must be able to handle
    /// at least n connections where n = num logical CPU cores.
    public var maxConnections: Int

    /// Creates a new `DatabaseConnectionPoolConfig`.
    ///
    /// - parameters:
    ///     - maxConnections: Maximum number of connections per pool.
    ///                       See `maxConnections` property docs for more information.
    public init(maxConnections: Int) {
        assert(maxConnections >= 1) // minimum supported value is 1
        self.maxConnections = maxConnections
    }
}
