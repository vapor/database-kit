public struct DatabaseIdentifier<Database>: Equatable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral
    where Database: DatabaseKit.Database
{
    /// The unique id.
    public let uid: String
    
    /// See `CustomStringConvertible`.
    public var description: String {
        return uid
    }
    
    /// Create a new `DatabaseIdentifier`.
    public init(_ uid: String) {
        self.uid = uid
    }
    
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
