import CoreLocation
import Foundation

final class CoreLocationService: NSObject, LocationServicing, CLLocationManagerDelegate {
    var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    var location: CLLocation? {
        manager.location
    }

    var onUpdate: (() -> Void)?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        publishUpdate()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        publishUpdate()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        publishUpdate()
    }

    private func publishUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.onUpdate?()
        }
    }
}
