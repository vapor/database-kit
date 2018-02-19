public struct SchemaQuery {
    public var statement: SchemaStatement
    public var table: String
    public var addColumns: [SchemaColumn]
    public var removeColumns: [String]
    public var addForeignKeys: [SchemaForeignKey]
    public var removeForeignKeys: [String]

    public init(
        statement: SchemaStatement,
        table: String,
        addColumns: [SchemaColumn],
        removeColumns: [String],
        addForeignKeys: [SchemaForeignKey],
        removeForeignKeys: [String]
    ) {
        self.statement = statement
        self.table = table
        self.addColumns = addColumns
        self.removeColumns = removeColumns
        self.addForeignKeys = addForeignKeys
        self.removeForeignKeys = removeForeignKeys
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
            removeColumns: [],
            addForeignKeys: foreignKeys,
            removeForeignKeys: []
        )
    }

    public static func alter(
        table: String,
        addColumns: [SchemaColumn],
        removeColumns: [String],
        addForeignKeys: [SchemaForeignKey],
        removeForeignKeys: [String]
    ) -> SchemaQuery {
        return .init(
            statement: .alter,
            table: table,
            addColumns: addColumns,
            removeColumns: removeColumns,
            addForeignKeys: addForeignKeys,
            removeForeignKeys: removeForeignKeys
        )
    }

    public static func drop(table: String) -> SchemaQuery {
        return SchemaQuery(
            statement: .drop,
            table: table,
            addColumns: [],
            removeColumns: [],
            addForeignKeys: [],
            removeForeignKeys: []
        )
    }
}
