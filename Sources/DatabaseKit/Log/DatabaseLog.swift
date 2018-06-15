/// Represents a database log.
public struct DatabaseLog: CustomStringConvertible {
    /// Database identifier.
    public let dbuid: String

    /// A string representing the query.
    public let query: String

    /// An array of strings reprensenting the values.
    public let values: [String]

    /// The time the log was created.
    public let date: Date

    /// See `CustomStringConvertible`.
    public var description: String {
        return "[" + dbuid + "] [" + date.description + "] " + query + " [" + values.joined(separator: ", ") + "]"
    }

    /// Create a new `DatabaseLog`.
    public init(dbuid: String = "db", query: String, values: [String] = [], date: Date = Date()) {
        self.dbuid = dbuid
        self.query = query
        self.values = values
        self.date = date
    }
}
