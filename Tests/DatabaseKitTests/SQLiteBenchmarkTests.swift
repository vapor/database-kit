import DatabaseKit
import XCTest
import NIO

final class DatabaseKitTests: XCTestCase {
    func testURLDatabaseName() {
        XCTAssertEqual(URL(string: "/vapor_database/asdf")?.databaseName, "vapor_database")
    }

    func testConnectionPooling() throws {
        let foo = FooDatabase(on: EmbeddedEventLoop())
        let pool = foo.makeConnectionPool(config: .init(maxConnections: 2))

        // make two connections
        let connA = try pool.requestConnection().wait()
        XCTAssertEqual(connA.isClosed, false)
        let connB = try pool.requestConnection().wait()
        XCTAssertEqual(connB.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // try to make a third, but pool only supports 2
        var connC: FooConnection?
        pool.requestConnection().whenSuccess { connC = $0 }
        XCTAssertNil(connC)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        XCTAssertNotNil(connC)
        XCTAssert(connC === connB)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // try to make a third again, with two active
        var connD: FooConnection?
        pool.requestConnection().whenSuccess { connD = $0 }
        XCTAssertNil(connD)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // this time, close the connection before releasing it
        try connC!.close().wait()
        pool.releaseConnection(connC!)
        XCTAssert(connD !== connB)
        XCTAssertEqual(connD?.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated, 3)
    }
    
    func testConnectionPoolPerformance() {
        let foo = FooDatabase(on: EmbeddedEventLoop())
        let pool = foo.makeConnectionPool(config: .init(maxConnections: 10))
        
        measure {
            for _ in 0..<10_000 {
                do {
                    let connA = try! pool.requestConnection().wait()
                    pool.releaseConnection(connA)
                }
                do {
                    let connA = try! pool.requestConnection().wait()
                    let connB = try! pool.requestConnection().wait()
                    let connC = try! pool.requestConnection().wait()
                    pool.releaseConnection(connB)
                    pool.releaseConnection(connC)
                    pool.releaseConnection(connA)
                }
                do {
                    let connA = try! pool.requestConnection().wait()
                    let connB = try! pool.requestConnection().wait()
                    pool.releaseConnection(connA)
                    pool.releaseConnection(connB)
                }
            }
        }
    }

    static let allTests = [
        ("testURLDatabaseName", testURLDatabaseName),
        ("testConnectionPooling", testConnectionPooling),
        ("testConnectionPoolPerformance", testConnectionPoolPerformance),
    ]
}

// MARK: Private

private final class FooDatabase: Database {
    typealias Connection = FooConnection

    var connectionsCreated: Int
    var eventLoop: EventLoop
    
    init(on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.connectionsCreated = 0
    }
    
    func makeConnection() -> EventLoopFuture<FooConnection> {
        connectionsCreated += 1
        return self.eventLoop.makeSucceededFuture(FooConnection(on: self.eventLoop))
    }
}

private final class FooConnection: DatabaseConnection {
    var isClosed: Bool
    let eventLoop: EventLoop

    init(on eventLoop: EventLoop) {
        self.isClosed = false
        self.eventLoop = eventLoop
    }

    func close() -> EventLoopFuture<Void> {
        self.isClosed = true
        return self.eventLoop.makeSucceededFuture(())
    }
}
