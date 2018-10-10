import NIO

public final class ConnectionPool<Database>
    where Database: DatabaseKit.Database
{
    public var eventLoop: EventLoop {
        return database.eventLoop
    }
    
    public struct Config {
        public static func `default`() -> Config {
            return .init(maxConnections: 20)
        }
        
        public var maxConnections: Int
    }
    
    /// This pool's configuration settings.
    public let config: Config
    
    private let database: Database
    
    private var activeConnections: Int
    private var connections: CircularBuffer<Database.Connection>
    private var waiters: CircularBuffer<EventLoopPromise<Database.Connection>>
    
    public init(database: Database, config: Config = .default()) {
        self.database = database
        self.config = config
        self.activeConnections = 0
        self.connections = .init()
        self.waiters = .init()
    }
    
    public func withConnection<T>(_ closure: @escaping (Database.Connection) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        return requestConnection().then { conn in
            return closure(conn).then { res in
                return self.releaseConnection(conn).map { res }
            }.thenIfError { err in
                return self.releaseConnection(conn).thenThrowing { throw err }
            }
        }
    }
    
    public func requestConnection() -> EventLoopFuture<Database.Connection> {
        if let conn = self.connections.popLast() {
            // check if it is still open
            if !conn.isClosed {
                // connection is still open, we can return it directly
                return self.eventLoop.newSucceededFuture(result: conn)
            } else {
                // connection is closed, we need to replace it
                return database.newConnection()
            }
        } else if activeConnections < config.maxConnections  {
            // all connections are busy, but we have room to open a new connection!
            self.activeConnections += 1
            // make the new connection
            return database.newConnection()
        } else {
            // connections are exhausted, we must wait for one to be returned
            let promise: EventLoopPromise<Database.Connection> = eventLoop.newPromise()
            waiters.append(promise)
            return promise.futureResult
        }
    }
    
    public func releaseConnection(_ conn: Database.Connection) -> EventLoopFuture<Void> {
        // add the connection back
        connections.append(conn)
        
        // now that we know a new connection is available, we should
        // take this chance to fulfill one of the waiters
        if let waiter = waiters.popLast() {
            requestConnection().cascade(promise: waiter)
        }
        
        // complete now, no need to wait
        return eventLoop.newSucceededFuture(result: ())
    }
}
