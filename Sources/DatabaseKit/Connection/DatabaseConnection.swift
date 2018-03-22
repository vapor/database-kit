import Async
import Service

/// Types conforming to this protocol can be used
/// as a database connection for executing queries.
public protocol DatabaseConnection: DatabaseConnectable, Extendable {
    /// Closes the database connection when finished.
    func close()
}

extension DatabaseConnection {
    /// See `DatabaseConnectable.connect(to:)`
    public func connect<D>(to database: DatabaseIdentifier<D>?) -> Future<D.Connection> {
        return Future.map(on: self) {
            guard let conn = self as? D.Connection else {
                throw DatabaseKitError(
                    identifier: "connectable",
                    reason: "Unexpected \(#function): \(self) not \(D.Connection.self)",
                    source: .capture()
                )
            }
            return conn
        }
    }
}

/// MARK: Deprecated

extension DatabaseConnection {
    @available(*, deprecated, message: "Implement on `DatabaseConnection` instead.")
    public var extend: Extend {
        get {
            let cache: ExtendCache
            if let existing = extendCache.currentValue {
                cache = existing
            } else {
                cache = .init()
                extendCache.currentValue = cache
            }

            let extend: Extend
            if let existing = cache.storage[.init(self)] {
                extend = existing
            } else {
                extend = .init()
                cache.storage[.init(self)] = extend
            }

            return extend
        }
        set {
            let cache: ExtendCache
            if let existing = extendCache.currentValue {
                cache = existing
            } else {
                cache = .init()
                extendCache.currentValue = cache
            }
            cache.storage[.init(self)] = newValue
        }
    }
}

fileprivate final class ExtendCache {
    var storage: [ObjectIdentifier: Extend]
    init() { storage = [:] }
}

fileprivate var extendCache: ThreadSpecificVariable<ExtendCache> = .init()
