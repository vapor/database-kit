public struct SchemaForeignKey {
    public var name: String
    public var local: DataColumn
    public var foreign: DataColumn
    public var onUpdate: SchemaForeignKeyAction?
    public var onDelete: SchemaForeignKeyAction?

    public init(name: String, local: DataColumn, foreign: DataColumn, onUpdate: SchemaForeignKeyAction?, onDelete: SchemaForeignKeyAction?) {
        self.name = name
        self.local = local
        self.foreign = foreign
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }
}

public enum SchemaForeignKeyAction {
    case noAction
    case restrict
    case setNull
    case setDefault
    case cascade
}
