import XCTest
@testable import TweeterServices

final class TweeterServicesTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TweeterServices().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
