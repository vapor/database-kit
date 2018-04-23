/// Swift `print` based `DatabaseLogHandler`.
public struct PrintLogHandler: DatabaseLogHandler {
    /// Creates a new `PrintLogHandler`.
    public init() { }

    /// See `DatabaseLogHandler`.
    public func record(log: DatabaseLog) {
        print(log.description)
    }
}
