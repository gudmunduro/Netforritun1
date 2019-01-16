import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(netforr1_serverTests.allTests),
    ]
}
#endif