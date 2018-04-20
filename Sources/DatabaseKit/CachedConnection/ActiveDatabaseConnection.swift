/// Represents an active connection.
internal final class ActiveDatabaseConnection {
    /// Handles connection release
    typealias OnRelease = () -> ()

    /// The unsafely typed connection
    var connection: Any?

    /// Call this on release
    var release: OnRelease?

    /// Creates a new `ActiveDatabaseConnection`
    init() {}
}

/// Caches active connections
internal final class ActiveDatabaseConnectionCache: Service {
    /// Storage
    var cache: [String: ActiveDatabaseConnection]

    /// Creates a new `ActiveDatabaseConnectionCache`
    init() {
        self.cache = [:]
    }
}
