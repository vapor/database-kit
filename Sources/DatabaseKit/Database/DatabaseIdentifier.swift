/// Each database in your application receives its own identifier.
///
/// Create identifiers for your non-default databases by adding
/// a static extension to this struct:
///
///     extension DatabaseIdentifier {
///         /// My custom DB.
///         public static var myCustom: DatabaseIdentifier<FooDatabase> {
///             return DatabaseIdentifier("foo-custom")
///         }
///     }
///
public struct DatabaseIdentifier<D: Database>: Equatable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral {
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
