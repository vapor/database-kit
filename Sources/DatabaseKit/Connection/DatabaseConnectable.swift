/// Capable of creating connections to identified databases.
///
/// Subsequent requests for a connection to the same database should always
/// yield the same connection.
///
/// Types conforming to this protocol are responsible for cleaning up open connections
/// in a way that makes sense to their use case. Usually on deinit.
public protocol DatabaseConnectable: Worker {
    /// Returns a `DatabaseConnection` to the identified `Database`.
    ///
    /// Subsequent calls to this method on the same type should always return the same connection.
    ///
    /// - parameters:
    ///     - dbid: `DatabaseIdentifier` of a database registered with `Databases`.
    ///             If set, this can be used to acquire a database reference for creating the connection.
    ///             if `nil`, the connection must be obtainable in another way (such as if `self` is the connection).
    /// - returns: A future containing the `DatabaseConnection`.
    func databaseConnection<Database>(to database: DatabaseIdentifier<Database>?) -> Future<Database.Connection>
}
