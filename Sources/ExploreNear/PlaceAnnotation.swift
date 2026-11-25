import MapKit
import Foundation

final class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let placeID: String

    init(place: Place) {
        self.coordinate = place.coordinate
        self.title = place.name
        self.subtitle = place.subtitle
        self.placeID = place.id
        super.init()
    }
}
