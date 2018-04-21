/// Registers `DatabaseKit` services.
public final class DatabaseKitProvider: Provider {
    /// Creates a new `DatabaseKitProvider`
    public init() {}

    /// See `Provider`.
    public func register(_ services: inout Services) throws {
        // database
        services.register(Databases.self)
        services.register(DatabaseConnectionCache.self)
        services.register(DatabaseConnectionPoolConfig.self)
        services.register(DatabaseConnectionPoolCache.self)
        
        // keyed cache
        services.register(MemoryKeyedCache(), as: KeyedCache.self)
        services.register(DictionaryKeyedCache.self)
    }

    /// See `Provider`.
    public func didBoot(_ worker: Container) throws -> Future<Void> {
        return .done(on: worker)
    }
}
