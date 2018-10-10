import DatabaseKit
import Foundation
import XCTest

final class DatabaseKitTests: XCTestCase {
    func testURLDatabaseName() {
        XCTAssertEqual(URL(string: "/vapor_database/asdf")?.databaseName, "vapor_database")
    }
    static let allTests = [
        ("testURLDatabaseName", testURLDatabaseName),
    ]
}
