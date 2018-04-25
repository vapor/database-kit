#if os(Linux)

import XCTest
@testable import DatabaseKitTests

XCTMain([
    // DatabaseKit
    testCase(DatabaseKitTests.allTests),
])

#endif
