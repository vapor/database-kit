public protocol DatabaseConnectable: Worker {
    func databaseConnection<D>(to database: DatabaseIdentifier<D>) -> Future<D.Connection>
}
