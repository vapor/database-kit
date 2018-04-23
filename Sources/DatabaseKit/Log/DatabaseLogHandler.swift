/// Capable of handling `Database` logs.
public protocol DatabaseLogHandler {
    /// Record the supplied `DatabaseLog`.
    /// - parameters:
    ///     - log: `DatabaseLog` to handle.
    func record(log: DatabaseLog)
}
