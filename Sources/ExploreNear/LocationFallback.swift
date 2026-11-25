import CoreLocation
import Foundation

enum LocationFallback {
    static let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    static let cityName = "San Francisco"

    static func resolve(
        authorizationStatus: CLAuthorizationStatus,
        location: CLLocation?
    ) -> (location: CLLocation, isFallback: Bool) {
        let isAuthorized: Bool
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
        case .notDetermined, .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }

        if isAuthorized, let location = location {
            return (location, false)
        }
        return (CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), true)
    }
}
