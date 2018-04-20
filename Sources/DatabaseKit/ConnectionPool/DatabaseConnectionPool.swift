/// Pools database connections for re-use.
public final class DatabaseConnectionPool<Database> where Database: DatabaseKit.Database {
    // MARK: Properties

    /// The database to use to generate new connections.
    public let database: Database

    /// The Worker for this pool
    public let eventLoop: EventLoop

    /// The maximum number of connections this pool should hold.
    public let maxCount: Int

    // MARK: Private Properties

    /// Available connections.
    private var actives: [ActiveDatabasePoolConnection<Database>]

    /// Notified when more connections are available.
    private var waiters: [Promise<Database.Connection>]

    /// Creates a new `DatabaseConnectionPool`.
    ///
    /// Use `Database.newConnectionPool(...)`.
    internal init(max: Int, database: Database, on worker: Worker) {
        self.database = database
        self.eventLoop = worker.eventLoop
        self.maxCount = max
        self.actives = []
        self.waiters = []
    }

    // MARK: Methods

    public func withConnection<T>(_ closure: @escaping (Database.Connection) throws -> Future<T>) -> Future<T> {
        let release = releaseConnection
        return requestConnection().flatMap(to: T.self) { conn in
            return try closure(conn).always { release(conn) }
        }
    }

    /// Request a connection from this queue pool.
    public func requestConnection() -> Future<Database.Connection> {
        if let active = actives.first(where: { $0.isAvailable }) {
            // there is an available connection, take it
            active.isAvailable = false

            // check if it is still open
            if !active.connection.isClosed {
                // connection is still open, we can return it directly
                return eventLoop.newSucceededFuture(result: active.connection)
            } else {
                // connection is closed, we need to replace it
                return database.newConnection(on: eventLoop).map { newConn in
                    // replace the connection with a new one
                    // this should cause the old connection to deinit now that
                    // there are no references to it
                    active.connection = newConn
                    return newConn
                }
            }
        } else if actives.count < maxCount  {
            // all connections are busy, but we have room to open a new connection!
            let active = ActiveDatabasePoolConnection<Database>()
            self.actives.append(active)

            // make the new connection
            return database.newConnection(on: eventLoop).map { newConn in
                active.connection = newConn
                return newConn
            }
        } else {
            // connections are exhausted, we must wait for one to be returned
            let promise = eventLoop.newPromise(Database.Connection.self)
            waiters.append(promise)
            return promise.futureResult
        }
    }

    /// Release a connection back to the queue pool.
    public func releaseConnection(_ conn: Database.Connection) {
        // get the active connection for this connection
        guard let active = actives.first(where: { $0.connection === conn }) else {
            assertionFailure("Attempted to release a connection to a pool that did not create it.")
            return
        }

        // mark it as available
        active.isAvailable = true

        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        if let waiter = waiters.popLast() {
            requestConnection().cascade(promise: waiter)
        }
    }
}

private final class ActiveDatabasePoolConnection<Database> where Database: DatabaseKit.Database {
    var connection: Database.Connection!
    var isAvailable: Bool
    init() {
        self.isAvailable = false
    }
}
