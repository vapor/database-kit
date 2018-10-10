import NIO

public protocol Database {
    associatedtype Connection: DatabaseKit.Connection
    var eventLoop: EventLoop { get }
    func newConnection() -> EventLoopFuture<Connection>
}

extension Database {
    public func withConnection<T>(_ closure: @escaping (Connection) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        return newConnection().then { conn in
            return closure(conn).then { res in
                return conn.close().map { res }
            }.thenIfError { err in
                return conn.close().thenThrowing { throw err }
            }
        }
    }
}
