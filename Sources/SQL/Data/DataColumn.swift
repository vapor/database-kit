/// A SQL column with optional table name.
public struct DataColumn {
    /// The table name for this column. If `nil`, it will be omitted.
    public var table: String?

    /// This column's name.
    public var name: String

    /// Optional key to rename this column.
    public var key: String?

    /// Creates a new SQL `DataColumn`.
    public init(table: String? = nil, name: String, key: String? = nil) {
        self.table = table
        self.name = name
        self.key = key
    }
}
