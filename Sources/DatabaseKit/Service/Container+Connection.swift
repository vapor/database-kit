import Async
import Service

/// Create connections that are automatically released when done.
extension Container {
    /// Returns a future database connection for the
    /// supplied database identifier if one can be fetched.
    /// The database connection will be cached on this worker.
    /// The same database connection will always be returned for
    /// a given worker.
    public func withConnection<Database, T>(
        to database: DatabaseIdentifier<Database>,
        closure: @escaping (Database.Connection) throws -> Future<T>
    ) -> Future<T> {
        return requestConnection(to: database).flatMap(to: T.self) { conn in
            return try closure(conn).map(to: T.self) { result in
                self.releaseConnection(conn, to: database)
                return result
            }
        }
    }
}

/// Request / release database connections.
extension Container {
    /// Requests a connection to the database.
    ///
    /// Call `.releaseConnection(_:to:)` on the connection when you are finished.
    public func requestConnection<Database>(
        to database: DatabaseIdentifier<Database>
    ) -> Future<Database.Connection> {
        return Future.flatMap(on: self) {
            let databases = try self.make(Databases.self)

            guard let db = databases.database(for: database) else {
                throw DatabaseKitError(identifier: "requestConnection", reason: "No database with id `\(database.uid)` is configured.", source: .capture())
            }

            return db.makeConnection(on: self)
        }
    }

    /// Releases a connection created by `.requestConnection(to:)`
    public func releaseConnection<Database>(
        _ conn: Database.Connection,
        to database: DatabaseIdentifier<Database>
    ) {
        conn.close()
    }
}
