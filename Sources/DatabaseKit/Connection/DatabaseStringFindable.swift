/// Capable of being looked up from a `String` on a `DatabaseConnection`.
///
/// This is useful for implementing databae models that can be found using routing parameters.
public protocol DatabaseStringFindable {
    /// The `Database` associated with this `Findable` type.
    associatedtype Database: DatabaseKit.Database

    /// Looks up an instance of `Self` using the supplied `String` on a `DatabaseConnection`.
    ///
    ///     let user = User.databaseFind("codevapor", on: conn)
    ///
    /// - parameters:
    ///     - string: `String` to use for looking up this model. Usually the model's ID.
    ///     - connection: An instance of the associated `Database`'s connection.
    /// - returns: Future containing optional `Self`, `nil` if no model could be found.
    func databaseFind(_ string: String, on conn: Database.Connection) -> Future<Self?>
}
