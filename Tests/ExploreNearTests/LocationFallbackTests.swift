import CoreLocation
import XCTest
@testable import ExploreNear

final class LocationFallbackTests: XCTestCase {
    private let actualLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)

    func testDeniedPermissionUsesSanFrancisco() {
        let result = LocationFallback.resolve(authorizationStatus: .denied, location: actualLocation)

        XCTAssertTrue(result.isFallback)
        XCTAssertEqual(result.location.coordinate.latitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(result.location.coordinate.longitude, -122.4194, accuracy: 0.0001)
    }

    func testAuthorizedWithoutLocationUsesSanFrancisco() {
        let result = LocationFallback.resolve(authorizationStatus: .authorizedWhenInUse, location: nil)

        XCTAssertTrue(result.isFallback)
        XCTAssertEqual(result.location.coordinate.latitude, 37.7749, accuracy: 0.0001)
    }

    func testNotDeterminedUsesSanFrancisco() {
        let result = LocationFallback.resolve(authorizationStatus: .notDetermined, location: actualLocation)

        XCTAssertTrue(result.isFallback)
    }

    func testAuthorizedWithLocationUsesActualLocation() {
        let result = LocationFallback.resolve(
            authorizationStatus: .authorizedWhenInUse,
            location: actualLocation
        )

        XCTAssertFalse(result.isFallback)
        XCTAssertEqual(result.location.coordinate.latitude, 40.7128, accuracy: 0.0001)
        XCTAssertEqual(result.location.coordinate.longitude, -74.0060, accuracy: 0.0001)
    }
}
