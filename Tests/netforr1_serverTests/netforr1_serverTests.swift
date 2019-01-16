import XCTest
@testable import netforr1_server

final class netforr1_serverTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(netforr1_server().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
