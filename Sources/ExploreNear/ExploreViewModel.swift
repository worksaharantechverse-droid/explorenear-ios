import Combine
import CoreLocation
import Foundation
import MapKit

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var selectedCategory: PlaceCategory = .coffee
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation = LocationFallback.resolve(
        authorizationStatus: .notDetermined,
        location: nil
    ).location
    @Published var isUsingFallback = true

    private let locationService: LocationServicing
    private let placeSearch: PlaceSearching

    init(
        locationService: LocationServicing? = nil,
        placeSearch: PlaceSearching? = nil
    ) {
        let resolvedLocationService = locationService ?? CoreLocationService()
        self.locationService = resolvedLocationService
        self.placeSearch = placeSearch ?? MapKitPlaceSearch()

        let resolved = LocationFallback.resolve(
            authorizationStatus: resolvedLocationService.authorizationStatus,
            location: resolvedLocationService.location
        )
        self.authorizationStatus = resolvedLocationService.authorizationStatus
        self.currentLocation = resolved.location
        self.isUsingFallback = resolved.isFallback
    }

    func start() {
        locationService.onUpdate = { [weak self] in
            Task { @MainActor in self?.handleLocationUpdate() }
        }

        if authorizationStatus == .notDetermined {
            locationService.requestWhenInUseAuthorization()
        }
        locationService.startUpdatingLocation()
        Task { await search() }
    }

    func stop() {
        locationService.stopUpdatingLocation()
    }

    func selectCategory(_ category: PlaceCategory) {
        guard category != selectedCategory else { return }
        selectedCategory = category
        Task { await search() }
    }

    func refresh() {
        Task { await search() }
    }

    func search() async {
        isLoading = true
        errorMessage = nil

        let coordinate = currentLocation.coordinate
        let category = selectedCategory
        let result: Result<[MKMapItem], Error> = await withCheckedContinuation { continuation in
            placeSearch.search(query: category.query, near: coordinate, radius: 5_000) { result in
                continuation.resume(returning: result)
            }
        }

        isLoading = false
        switch result {
        case .success(let items):
            places = items
                .map { Place(mapItem: $0, origin: currentLocation) }
                .sorted { $0.distance < $1.distance }
            if places.isEmpty {
                errorMessage = "No \(category.title.lowercased()) found nearby."
            }
        case .failure(let error):
            places = []
            errorMessage = error.localizedDescription
        }
    }

    private func handleLocationUpdate() {
        authorizationStatus = locationService.authorizationStatus
        let resolved = LocationFallback.resolve(
            authorizationStatus: authorizationStatus,
            location: locationService.location
        )
        currentLocation = resolved.location
        isUsingFallback = resolved.isFallback
        Task { await search() }
    }
}
