# Architecture — ExploreNear

## Layers

| Layer | Types | Responsibility |
|-------|-------|----------------|
| Model | `Place`, `PlaceCategory`, `PlaceAnnotation` | Search results and map annotations |
| Services | `LocationServicing`, `MapKitPlaceSearch` | CoreLocation and MKLocalSearch wrappers |
| Fallback | `LocationFallback`, `DistanceFormatter` | Default coordinate and pure formatting |
| ViewModel | `ExploreViewModel` | Category selection, results and error state |
| Views | `ExploreViewController`, `PlaceDetailViewController` | Programmatic map/list/detail UI |

## Search flow

The view model requests a location from `LocationServicing`. If permission is denied or unavailable, `LocationFallback` supplies San Francisco and the UI displays a banner. `MapKitPlaceSearch` then runs an `MKLocalSearch` request for the selected category and maps results to `Place` values.

## Testability

Location and search are protocol-based. Distance formatting and fallback logic are pure functions, enabling unit tests without CoreLocation or MapKit side effects.

## SOLID application

- Single responsibility: location, search and formatting are separate.
- Dependency inversion: the view model depends on abstractions.
- Liskov substitution: mock services can replace real location/search in tests.
