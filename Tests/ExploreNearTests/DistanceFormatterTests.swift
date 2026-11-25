import XCTest
@testable import ExploreNear

final class DistanceFormatterTests: XCTestCase {
    func testMeters() {
        XCTAssertEqual(DistanceFormatter.string(from: 0), "0 m")
        XCTAssertEqual(DistanceFormatter.string(from: 500), "500 m")
        XCTAssertEqual(DistanceFormatter.string(from: 999), "999 m")
    }

    func testKilometers() {
        XCTAssertEqual(DistanceFormatter.string(from: 1_000), "1.0 km")
        XCTAssertEqual(DistanceFormatter.string(from: 1_500), "1.5 km")
    }
}
