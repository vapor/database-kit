import Async
import DatabaseKit
import XCTest

final class DatabaseKitTests: XCTestCase {
    func testURLDatabaseName() {
        XCTAssertEqual(URL(string: "/vapor_database/asdf")?.databaseName, "vapor_database")
    }

    static let allTests = [
        ("testURLDatabaseName", testURLDatabaseName),
    ]
}
