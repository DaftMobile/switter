#if os(Linux)

import XCTest
@testable import LogicTests

XCTMain([
    testCase(RouteTests.allTests)
])

#endif
