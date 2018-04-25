import Debugging

/// Errors that can be thrown while working with Vapor.
public struct DatabaseKitError: Debuggable {
    /// See `Debuggable`.
    public static let readableName = "DatabaseKit Error"

    /// See `Debuggable`.
    public let identifier: String

    /// See `Debuggable`.
    public var reason: String

    /// See `Debuggable`.
    public var sourceLocation: SourceLocation?

    /// See `Debuggable`.
    public var stackTrace: [String]

    /// See `Debuggable`.
    public var suggestedFixes: [String]

    /// See `Debuggable`.
    public var possibleCauses: [String]

    /// Creates a new `DatabaseKitError`.
    init(
        identifier: String,
        reason: String,
        suggestedFixes: [String] = [],
        possibleCauses: [String] = [],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = SourceLocation(file: file, function: function, line: line, column: column, range: nil)
        self.stackTrace = DatabaseKitError.makeStackTrace()
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
    }
}

/// For printing un-handleable errors.
func ERROR(_ string: @autoclosure () -> String, file: StaticString = #file, line: Int = #line) {
    print("[DatabaseKit] \(string()) [\(file.description.split(separator: "/").last!):\(line)]")
}

/// Only includes the supplied closure in non-release builds.
internal func debugOnly(_ body: () -> Void) {
    assert({ body(); return true }())
}
