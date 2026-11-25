import CoreLocation
import Foundation
import MapKit

final class MapKitPlaceSearch: PlaceSearching {
    private var activeSearch: MKLocalSearch?

    func search(
        query: String,
        near coordinate: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        completion: @escaping (Result<[MKMapItem], Error>) -> Void
    ) {
        activeSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )

        let search = MKLocalSearch(request: request)
        activeSearch = search
        search.start { [weak self] response, error in
            let result: Result<[MKMapItem], Error>
            if let error = error {
                result = .failure(error)
            } else {
                result = .success(response?.mapItems ?? [])
            }

            DispatchQueue.main.async {
                self?.activeSearch = nil
                completion(result)
            }
        }
    }
}
