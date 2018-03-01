import Async
import Service
import Dispatch

/// Pools database connections for re-use.
public final class DatabaseConnectionPool<Database> where Database: DatabaseKit.Database {
    /// The database to use to generate new connections.
    public let database: Database

    /// The Worker for this pool
    public let eventLoop: EventLoop

    /// The maximum number of connections this pool should hold.
    public let max: UInt

    /// The current number of active connections.
    private var active: UInt

    /// Available connections.
    private var available: [Database.Connection]

    /// Notified when more connections are available.
    private var waiters: [(Database.Connection) -> ()]

    /// Create a new Queue pool
    public init(
        max: UInt,
        database: Database,
        on worker: Worker
    ) {
        self.database = database
        self.eventLoop = worker.eventLoop
        self.max = max
        self.active = 0
        self.available = []
        self.waiters = []
    }

    /// Request a connection from this queue pool.
    public func requestConnection() -> Future<Database.Connection> {
        let promise = eventLoop.newPromise(Database.Connection.self)

        if let ready = self.available.popLast() {
            promise.succeed(result: ready)
        } else if self.active < self.max {
            self.database.makeConnection(on: wrap(eventLoop)).do { connection in
                self.active += 1
                promise.succeed(result: connection)
            }.catch { err in
                promise.fail(error: err)
            }
        } else {
            self.waiters.append(promise.succeed)
        }

        return promise.futureResult
    }

    /// Release a connection back to the queue pool.
    public func releaseConnection(_ connection: Database.Connection) {
        if let waiter = self.waiters.popLast() {
            waiter(connection)
        } else {
            self.available.append(connection)
        }
    }
}

