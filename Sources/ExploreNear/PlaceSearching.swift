import CoreLocation
import Foundation
import MapKit

protocol PlaceSearching: AnyObject {
    func search(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[MKMapItem], Error>) -> Void
    )
}
