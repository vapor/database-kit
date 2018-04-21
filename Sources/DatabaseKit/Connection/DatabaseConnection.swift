/// Types conforming to this protocol can be used as a `Database.Connection`.
///
/// Most of the database interaction work is done through static methods on `Database` that accept
/// a connection. However, there are a few things like `isClosed` and `close()` that a connection must implement.
public protocol DatabaseConnection: Worker, Extendable {
    /// If `true`, this connection has been closed and is no longer valid.
    /// This is used by `DatabaseConnectionPool` to prune inactive connections.
    var isClosed: Bool { get }

    /// Closes the `DatabaseConnection`.
    func close()
}
