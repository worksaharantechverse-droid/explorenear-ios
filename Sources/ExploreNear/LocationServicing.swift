import CoreLocation
import Foundation

protocol LocationServicing: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    var onUpdate: (() -> Void)? { get set }

    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
