public struct SchemaQuery {
    public var statement: SchemaStatement
    public var table: String
    public var addColumns: [SchemaColumn]
    public var deleteColumns: [String]
    public var addForeignKeys: [SchemaForeignKey]
    public var deleteForeignKeys: [String]

    public init(
        statement: SchemaStatement,
        table: String,
        addColumns: [SchemaColumn],
        deleteColumns: [String],
        addForeignKeys: [SchemaForeignKey],
        deleteForeignKeys: [String]
    ) {
        self.statement = statement
        self.table = table
        self.addColumns = addColumns
        self.addForeignKeys = addForeignKeys
        self.deleteColumns = deleteColumns
        self.deleteForeignKeys = deleteForeignKeys
    }

    public static func create(
        table: String,
        columns: [SchemaColumn],
        foreignKeys: [SchemaForeignKey]
    ) -> SchemaQuery {
        return .init(
            statement: .create,
            table: table,
            addColumns: columns,
            deleteColumns: [],
            addForeignKeys: foreignKeys,
            deleteForeignKeys: []
        )
    }

    public static func alter(
        table: String,
        columns: [SchemaColumn],
        deleteColumns: [String],
        deleteForeignKeys: [String]
    ) -> SchemaQuery {
        return .init(
            statement: .alter,
            table: table,
            addColumns: columns,
            deleteColumns: deleteColumns,
            addForeignKeys: [],
            deleteForeignKeys: deleteForeignKeys
        )
    }

    public static func drop(table: String) -> SchemaQuery {
        return SchemaQuery(statement: .drop, table: table, addColumns: [], deleteColumns: [], addForeignKeys: [], deleteForeignKeys: [])
    }
}
