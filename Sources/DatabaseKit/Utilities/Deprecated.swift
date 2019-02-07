import NIO

/// nothing here yet...

extension Databases {
    @available(*, unavailable, message: "Register a database instance instead.")
    public mutating func add<D>(database: D.Type, as id: DatabaseIdentifier<D>) {
        fatalError()
    }
    
    @available(*, unavailable, message: "Register a database instance instead.")
    public mutating func add<D>(as id: DatabaseIdentifier<D>, database: @escaping (Any) throws -> D) {
        fatalError()
    }

    @available(*, unavailable, renamed: "resolve")
    public func resolve(on container: Any) throws -> Databases {
        fatalError()
    }
    
    @available(*, unavailable, message: "Enable logging in database specific config instead.")
    public mutating func enableLogging<D>(on db: DatabaseIdentifier<D>, logger: Any) {
        fatalError()
    }
    
    @available(*, unavailable, message: "Use database specific config instead.")
    public mutating func appendConfigurationHandler<D>(on db: DatabaseIdentifier<D>, _ configure: @escaping (D.Connection) -> EventLoopFuture<Void>) {
        fatalError()
    }
}

@available(*, unavailable, renamed: "Databases")
public typealias DatabasesConfig = Databases

@available(*, unavailable, renamed: "ConnectionPool")
public typealias DatabaseConnectionPool = Any

@available(*, unavailable, renamed: "ConnectionPoolConfig")
public typealias DatabaseConnectionPoolConfig = Any

@available(*, unavailable, message: "Use ORM-specific database protocol instead.")
public typealias DatabaseQueryable = Any

@available(*, unavailable, message: "Use ORM-specific database protocol instead.")
public typealias DatabaseConnectable = Any

@available(*, unavailable)
public typealias DatabaseStringFindable = Any

@available(*, unavailable, message: "Enable logging in database specific config instead.")
public typealias LogSupporting = Any
