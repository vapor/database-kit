/// Types conforming to this protocol can be used as a database connection for executing queries.
public protocol DatabaseConnection: Worker, Extendable {
    var isClosed: Bool { get }

    /// Closes the database connection when finished.
    func close()
}
