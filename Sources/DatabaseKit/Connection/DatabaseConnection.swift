/// Types conforming to this protocol can be used as a `Database.Connection`.
///
/// Most of the database interaction work is done through static methods on `Database` that accept
/// a connection. However, there are a few things like `isClosed` and `close()` that a connection must implement.
public protocol DatabaseConnection: ConnectionPoolItem {
    /// This connection's event loop.
    var eventLoop: EventLoop { get }

    /// Closes the `DatabaseConnection`.
    func close() -> EventLoopFuture<Void>
}
