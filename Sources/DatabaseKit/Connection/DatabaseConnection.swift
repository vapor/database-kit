import Async

/// Types conforming to this protocol can be used
/// as a database connection for executing queries.
public protocol DatabaseConnection: DatabaseConnectable {
    /// Closes the database connection when finished.
    func close()
}


extension DatabaseConnection {
    /// See `DatabaseConnectable.connect(to:)`
    public func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        guard let conn = self as? D.Connection else {
            let error = DatabaseKitError(identifier: "connectable", reason: "Unexpected \(#function): \(self) not \(D.Connection.self)", source: .capture())
            return Future(error: error)
        }
        return Future(conn)
    }
}
