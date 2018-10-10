import NIO

public protocol Connection {
    var eventLoop: EventLoop { get }
    var isClosed: Bool { get }
    func close() -> EventLoopFuture<Void>
}
