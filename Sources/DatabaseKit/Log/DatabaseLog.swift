<<<<<<< HEAD
/// Capable of logging queries through a supplied DatabaseLogger.
=======
/// Capable of logging queries through a supplied `DatabaseLogger`.
>>>>>>> e7525aabb2828bfa96c109a73c073c693f949f12
public protocol LogSupporting {
    /// Enables query logging to the supplied `DatabaseLogger`.
    func enableLogging(using logger: DatabaseLogger)
}

/// Represents a database log.
public struct DatabaseLog: CustomStringConvertible {
    /// Database identifier.
    var dbID: String

    /// A string representing the query.
    var query: String

    /// An array of strings reprensenting the values.
    var values: [String]

    /// The time the log was created.
    var date: Date

    /// See `CustomStringConvertible`.
    public var description: String {
        return "[\(dbID)] [\(date)] \(query) \(values)"
    }

    /// Create a new `DatabaseLog`.
    public init(query: String, values: [String] = [], dbID: String = "db", date: Date = Date()) {
        self.query = query
        self.values = values
        self.date = date
        self.dbID = dbID
    }
}
