/// A database query, schema, tranasaction, etc logger.
public final class DatabaseLogger {
    /// Current `DatabaseLogHandler`.
    public let handler: DatabaseLogHandler

    /// Database identifier.
    private let dbuid: String

    /// Create a new database logger.
    public init<D>(database: DatabaseIdentifier<D>, handler: DatabaseLogHandler) {
        self.dbuid = database.uid
        self.handler = handler
    }

    /// Records a database log to the current handler.
    public func record(query: String, values: [String] = []) {
        let log = DatabaseLog(dbuid: dbuid, query: query, values: values, date: .init())
        return handler.record(log: log)
    }
}
