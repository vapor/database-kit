public struct ThreadConnectionPool {
    public let databases: Databases
    public let config: ConnectionPoolConfig
    
    private final class PoolStorage {
        var pools: [String: Any]
        init() {
            self.pools = [:]
        }
    }
    
    private var poolStorage = ThreadSpecificVariable<PoolStorage>()
    
    public init(databases: Databases, config: ConnectionPoolConfig) {
        self.databases = databases
        self.config = config
    }
    
    public func get<D>(for dbid: DatabaseIdentifier<D>) throws -> ConnectionPool<D> {
        if let storage = self.poolStorage.currentValue {
            if let pool = storage.pools[dbid.uid] as? ConnectionPool<D> {
                return pool
            } else {
                let pool = try self.databases.requireDatabase(for: dbid)
                    .makeConnectionPool(config: config)
                storage.pools[dbid.uid] = pool
                return pool
            }
        } else {
            let storage = PoolStorage()
            self.poolStorage.currentValue = storage
            let pool = try self.databases.requireDatabase(for: dbid)
                .makeConnectionPool(config: config)
            storage.pools[dbid.uid] = pool
            return pool
        }
    }
}
