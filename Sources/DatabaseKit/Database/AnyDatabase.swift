/// Simple closure-based struct `Database` implementation. Will return the same kind of connections
/// the generic `Database` type does.
///
/// This type is used internally to create wrappers around `Database`s that can implement custom logic.
/// For example: enabling logging or foreign key constraints on new connections as they are created.
public struct AnyDatabase<D>: Database where D: Database {
    /// Private `newConnection` implementation.
    private let newConnectionClosure: (Worker) -> Future<D.Connection>

    /// Creates a new `AnyDatabase`.
    fileprivate init<Other>(_ database: Other) where Other: Database, Other.Connection == D.Connection {
        self.newConnectionClosure = database.newConnection
    }

    /// See `Database`.
    public func newConnection(on worker: Worker) -> Future<D.Connection> {
        return newConnectionClosure(worker)
    }
}

extension Database {
    /// Creates an `AnyDatabase` wrapper around this database to a different `Database` type.
    public func anyDatabase<D>(_ type: D.Type = D.self) -> AnyDatabase<D> where D.Connection == Self.Connection {
        return .init(self)
    }
}

extension AnyDatabase: KeyedCacheSupporting where D: KeyedCacheSupporting {
    // MARK: Keyed Cache

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheGet<T>(_ key: String, as decodable: T.Type, on conn: Connection) throws -> Future<T?>
        where T: Decodable
    {
        return try D.keyedCacheGet(key, as: T.self, on: conn)
    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheSet<E>(_ key: String, to encodable: E, on conn: D.Connection) throws -> Future<Void>
        where E: Encodable
    {
        return try D.keyedCacheSet(key, to: encodable, on: conn)
    }

    /// See `KeyedCacheSupporting`.
    public static func keyedCacheRemove(_ key: String, on conn: D.Connection) throws -> Future<Void> {
        return try D.keyedCacheRemove(key, on: conn)
    }
}
