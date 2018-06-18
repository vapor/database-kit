/// Types conforming to this protocol can be used as a `Database.Connection`.
///
/// Most of the database interaction work is done through static methods on `Database` that accept
/// a connection. However, there are a few things like `isClosed` and `close()` that a connection must implement.
public protocol DatabaseConnection: DatabaseConnectable, Extendable {
    /// This connection's associated database type.
    associatedtype Database: DatabaseKit.Database
        where Database.Connection == Self
    
    /// If `true`, this connection has been closed and is no longer valid.
    /// This is used by `DatabaseConnectionPool` to prune inactive connections.
    var isClosed: Bool { get }

    /// Closes the `DatabaseConnection`.
    func close()
}

public protocol DatabaseQueryable {
    associatedtype Query
    associatedtype Output
    
    func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>
}

extension DatabaseConnectionPool: DatabaseQueryable where Database.Connection: DatabaseQueryable {
    public typealias Query = Database.Connection.Query
    public typealias Output = Database.Connection.Output
    
    public func query(_ query: Database.Connection.Query, _ handler: @escaping (Database.Connection.Output) throws -> ()) -> Future<Void> {
        return withConnection { conn in
            return conn.query(query, handler)
        }
    }
}

extension DatabaseQueryable {
    /// Executes the supplied `SQLiteQuery` on the connection, aggregating the results into an array.
    ///
    ///     let rows = try conn.query("SELECT * FROM users").wait()
    ///
    /// - parameters:
    ///     - query: `SQLiteQuery` to execute.
    /// - returns: A `Future` containing array of rows.
    public func query(_ query: Query) -> Future<[Output]> {
        var rows: [Output] = []
        return self.query(query) { rows.append($0) }.map { rows }
    }
}

extension DatabaseConnection {
    /// See `DatabaseConnectable`.
    public func databaseConnection<Database>(to database: DatabaseIdentifier<Database>?) -> Future<Database.Connection> {
        let future: Future<Database.Connection>
        if let conn = self as? Database.Connection {
            future = eventLoop.newSucceededFuture(result: conn)
        } else {
            let error = DatabaseKitError(
                identifier: "databaseConnectable",
                reason: "Could not convert `\(Self.self)` to `\(Database.Connection.self)`.",
                possibleCauses: [
                    "You are using a database connection from a different database."
                ]
            )
            future = eventLoop.newFailedFuture(error: error)
        }
        return future
    }
}
