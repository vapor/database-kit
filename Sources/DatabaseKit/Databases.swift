public struct Databases {
    private var storage: [String: Any]
    
    public init() {
        self.storage = [:]
    }
    
    public mutating func add<D>(database: D, as id: DatabaseIdentifier<D>) {
        assert(self.storage[id.uid] == nil, "A database with id '\(id.uid)' is already registered")
        self.storage[id.uid] = database
    }
    
    public func connectionPool<Database>(
        for dbid: DatabaseIdentifier<Database>,
        config: ConnectionPool<Database>.Config = .default()
    ) -> ConnectionPool<Database>? {
        guard let db = self.database(for: dbid) else {
            return nil
        }
        return .init(database: db, config: config)
    }
    
    public func database<Database>(for dbid: DatabaseIdentifier<Database>) -> Database? {
        guard let db = self.storage[dbid.uid] as? Database else {
            return nil
        }
        return db
    }
}
