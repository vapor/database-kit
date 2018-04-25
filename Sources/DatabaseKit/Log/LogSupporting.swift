/// Capable of logging queries through a supplied `DatabaseLogger`.
public protocol LogSupporting: Database {
    /// Enables query logging to the supplied `DatabaseLogger`.
    static func enableLogging(_ logger: DatabaseLogger, on conn: Self.Connection)
}
