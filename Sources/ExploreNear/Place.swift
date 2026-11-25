import CoreLocation
import Foundation
import MapKit

struct Place: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let distance: CLLocationDistance
    let phoneNumber: String?
    let url: URL?
    let mapItem: MKMapItem

    init(mapItem: MKMapItem, origin: CLLocation) {
        let coordinate = mapItem.placemark.coordinate
        let name = mapItem.name ?? "Unknown place"
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        self.id = "\(name)-\(coordinate.latitude)-\(coordinate.longitude)"
        self.name = name
        self.subtitle = mapItem.placemark.title ?? mapItem.placemark.locality ?? "Nearby place"
        self.coordinate = coordinate
        self.distance = location.distance(from: origin)
        self.phoneNumber = mapItem.phoneNumber
        self.url = mapItem.url
        self.mapItem = mapItem
    }
}
