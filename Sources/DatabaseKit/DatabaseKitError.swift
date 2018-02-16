import Debugging

/// Errors that can be thrown while working with Vapor.
public struct DatabaseKitError: Traceable, Debuggable, Swift.Error, Encodable, Helpable {
    public static let readableName = "DatabaseKit Error"
    public let identifier: String
    public var reason: String
    public var file: String
    public var function: String
    public var line: UInt
    public var column: UInt
    public var stackTrace: [String]
    public var suggestedFixes: [String]
    public var possibleCauses: [String]

    init(
        identifier: String,
        reason: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        suggestedFixes: [String] = [],
        possibleCauses: [String] = []
    ) {
        self.identifier = identifier
        self.reason = reason
        self.file = file
        self.function = function
        self.line = line
        self.column = column
        self.stackTrace = DatabaseKitError.makeStackTrace()
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
    }
}

/// For printing un-handleable errors.
func ERROR(_ string: @autoclosure () -> String, file: StaticString = #file, line: Int = #line) {
    print("[DatabaseKit] \(string()) [\(file.description.split(separator: "/").last!):\(line)]")
}
