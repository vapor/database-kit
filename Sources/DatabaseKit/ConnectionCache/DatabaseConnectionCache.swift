/// Caches active connections
internal final class DatabaseConnectionCache: ServiceType {
    /// Storage
    var cache: [String: CachedDatabaseConnection]

    /// Creates a new `ActiveDatabaseConnectionCache`
    init() {
        self.cache = [:]
    }

    /// See `ServiceType`.
    static func makeService(for worker: Container) throws -> DatabaseConnectionCache {
        return .init()
    }
}

/// Represents an active connection.
internal final class CachedDatabaseConnection {
    /// Handles connection release
    typealias OnRelease = () -> ()

    /// The unsafely typed connection
    var connection: Any?

    /// Call this on release
    var release: OnRelease?

    /// Creates a new `ActiveDatabaseConnection`
    init() {}
}
