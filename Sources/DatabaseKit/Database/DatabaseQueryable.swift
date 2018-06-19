/// Capable of asynchronously executing a generic `Query`, passing zero or more output to a supplied handler.
public protocol DatabaseQueryable {
    /// Associated query type.
    associatedtype Query
    
    /// Associated query output type.
    associatedtype Output
    
    /// Asynchronously executes a query passing zero or more output to the supplied handler.
    ///
    ///     let rows = try conn.query(...) { output in
    ///         print(output)
    ///     }.wait()
    ///
    /// - parameters:
    ///     - query: `Query` to execute.
    ///     - handler: Output handler.
    /// - returns: A `Future` that signals completion.
    func query(_ query: Query, _ handler: @escaping (Output) throws -> ()) -> Future<Void>
}

/// Conforms `DatabaseConnectionPool` to `DatabaseQueryable` where its connection type conforms.
extension DatabaseConnectionPool: DatabaseQueryable where Database.Connection: DatabaseQueryable {
    /// See `DatabaseQueryable`.
    public typealias Query = Database.Connection.Query
    
    /// See `DatabaseQueryable`.
    public typealias Output = Database.Connection.Output
    
    /// See `DatabaseQueryable`.
    public func query(_ query: Database.Connection.Query, _ handler: @escaping (Database.Connection.Output) throws -> ()) -> Future<Void> {
        return withConnection { conn in
            return conn.query(query, handler)
        }
    }
}

extension DatabaseQueryable {
    /// Executes the supplied `Query`, aggregating the results into an array.
    ///
    ///     let rows = try conn.query(...).wait()
    ///
    /// - parameters:
    ///     - query: `Query` to execute.
    /// - returns: A `Future` containing array of output.
    public func query(_ query: Query) -> Future<[Output]> {
        var rows: [Output] = []
        return self.query(query) { rows.append($0) }.map { rows }
    }
}
