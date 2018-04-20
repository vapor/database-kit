import DatabaseKit
import XCTest

final class DatabaseKitTests: XCTestCase {
    func testURLDatabaseName() {
        XCTAssertEqual(URL(string: "/vapor_database/asdf")?.databaseName, "vapor_database")
    }

    func testConnectionPooling() throws {
        let foo = FooDatabase()
        let pool = foo.newConnectionPool(max: 2, on: EmbeddedEventLoop())

        // make two connections
        let connA = try pool.requestConnection().wait()
        XCTAssertEqual(connA.isClosed, false)
        let connB = try pool.requestConnection().wait()
        XCTAssertEqual(connB.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // try to make a third, but pool only supports 2
        var connC: FooConnection?
        pool.requestConnection().do { connC = $0 }.catch { XCTFail("\($0)") }
        XCTAssertNil(connC)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // release one of the connections, allowing the third to be made
        pool.releaseConnection(connB)
        XCTAssertNotNil(connC)
        XCTAssert(connC === connB)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // try to make a third again, with two active
        var connD: FooConnection?
        pool.requestConnection().do { connD = $0 }.catch { XCTFail("\($0)") }
        XCTAssertNil(connD)
        XCTAssertEqual(foo.connectionsCreated, 2)

        // this time, close the connection before releasing it
        connC!.close()
        pool.releaseConnection(connC!)
        XCTAssert(connD !== connB)
        XCTAssertEqual(connD?.isClosed, false)
        XCTAssertEqual(foo.connectionsCreated, 3)
    }

    static let allTests = [
        ("testURLDatabaseName", testURLDatabaseName),
        ("testConnectionPooling", testConnectionPooling),
    ]
}

// MARK: Private

private final class FooDatabase: Database {
    var connectionsCreated: Int
    init() {
        self.connectionsCreated = 0
    }
    func newConnection(on worker: Worker) -> EventLoopFuture<FooConnection> {
        connectionsCreated += 1
        return worker.eventLoop.newSucceededFuture(result: FooConnection(on: worker))
    }
}

private final class FooConnection: BasicWorker, DatabaseConnection {
    var isClosed: Bool
    var extend: Extend
    let eventLoop: EventLoop

    init(on worker: Worker) {
        self.isClosed = false
        self.eventLoop = worker.eventLoop
        self.extend = [:]
    }

    func close() {
        isClosed = true
    }
}
