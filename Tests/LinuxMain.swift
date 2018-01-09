#if os(Linux)

import XCTest
@testable import DatabaseKitTests
@testable import SQLTests

XCTMain([
    // DatabaseKit
    testCase(DatabaseKitTests.allTests),

    // SQL
    testCase(DataTests.allTests),
    testCase(SchemaTests.allTests),
])

#endif
